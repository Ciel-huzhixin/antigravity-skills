---
name: lean-frontend-coding
description: >-
  用于指导编写精益、清晰、无冗余防御性代码的 Web 前端代码。当生成或重构 React/Vue/TypeScript 前端组件、接口请求及数据处理逻辑时使用。严格禁止滥用多重字段猜测与层层兜底（如 a || b || c），强调契约优先、类型信任以及在字段不明确时主动向用户澄清。
---

# 精益前端开发规范 (Lean Frontend Coding)

在编写 Web 前端业务逻辑与组件代码时，遵循**契约优先、强类型信任、拒绝过度防御**的原则。AI 在生成代码时往往倾向于极端的防御性策略（如通过多个 `||` 猜测可能存在的不同字段命名），这不仅降低了代码的可读性与维护性，还掩盖了真正的数据契约错误。

---

## 核心准则 (Core Principles)

### 1. 契约优先与类型信任 (Contract First & Type Trust)
- **信任契约**：前端代码应当基于明确的 API 响应契约或 TypeScript 接口定义编写。
- **单一定义**：接口字段是什么就写什么，严禁在消费数据时自作聪明地做多重兼容猜测。

### 2. 严禁字段猜测级联 (No Field-Guessing Cascades)
- **绝对禁止**以下模式：
  - `const id = item.id || item._id || item.key;`
  - `const title = item.title || item.name || item.label || '无标题';`
  - `const list = res?.data?.list || res?.data?.items || res?.data?.data || [];`
- **危害**：这种代码会导致数据流向不清晰，把本应在接口联调阶段暴露的问题强行压制，产生不可控的隐形 Bug。

### 3. 不确定时主动确认 (Ask, Don't Guess)
- **何时提问**：当上下文中没有提供 API 文档、接口响应结构或 TypeScript 类型，且无法从现有代码库准确推断时。
- **如何提问**：停止猜测字段名，直接向用户明确询问：
  > “请提供该接口返回的数据结构或 TypeScript 类型定义，以便精确消费字段，避免生成冗余的兜底代码。”

### 4. 正确区分“业务默认值”与“过度防御”
- **业务默认值（允许并推荐）**：
  业务需求明确要求某字段为空时展示特定占位。
  - 正例：`const avatarUrl = user.avatarUrl ?? DEFAULT_AVATAR;`（用户未上传头像，业务要求展示默认头像）
- **过度防御（坚决反对）**：
  因为不确定后端返回的属性名而并列多个候选字段。
  - 反例：`const name = user.username || user.userName || user.name || '未知';`

### 5. 边界校验，内部信任 (Validate at Boundaries, Trust Internally)
- 若外部数据输入环境不可信（如第三方未知数据源），应在**网络请求边界层**使用类型断言或验证库（如 Zod / TypeScript Guards）统一校验并标准化为干净的内部数据结构。
- 业务组件内部消费时直接信任标准类型，不再重复做多层深层解构与兜底。

---

## 典型场景对比

### 场景一：接口列表数据消费

#### ❌ 错误示范（过度防御、字段猜测）
```typescript
// 反模式：层层可选链与多字段试探
const fetchUserList = async () => {
  const res = await api.getUsers();
  const list = res?.data?.list || res?.data?.records || res?.data?.items || res?.data || [];
  setUsers(list.map(item => ({
    id: item?.id || item?._id || item?.userId || '',
    name: item?.name || item?.userName || item?.nickName || '未命名',
  })));
};
```

#### ✅ 正确示范（明确契约、干净利落）
```typescript
interface UserResponse {
  list: Array<{
    id: string;
    userName: string;
  }>;
  total: number;
}

const fetchUserList = async () => {
  const { data } = await api.getUsers<UserResponse>();
  // 契约明确，直接使用
  setUsers(data.list.map(item => ({
    id: item.id,
    name: item.userName,
  })));
};
```

---

### 场景二：深层对象可选链滥用

#### ❌ 错误示范
```typescript
// 页面逻辑已经前置校验了 order 必须存在，但后续各处仍然在做无意义的链式防御
const OrderDetail = ({ order }: { order: Order }) => {
  return (
    <div>
      <h1>{order?.orderInfo?.basic?.title || '暂无数据'}</h1>
      <p>{order?.orderInfo?.basic?.status?.name || '未知状态'}</p>
    </div>
  );
};
```

#### ✅ 正确示范
```typescript
// 既然传入的 order 符合类型契约，直接精准访问所需属性
const OrderDetail = ({ order }: { order: Order }) => {
  const { title, status } = order.orderInfo.basic;
  return (
    <div>
      <h1>{title}</h1>
      <p>{status.name}</p>
    </div>
  );
};
```

---

## 协作工作流清单 (Workflow Checklist)

在为用户编写前端代码时，按以下流程推进：

1. **查验契约**：首先检索项目内已有的 `types/`、API 封装文件或上下文字段。
2. **主动发问**：若字段缺乏上下文或可能存在歧义，**立即询问用户确认**，切忌脑补多个属性名相互 `||` 兜底。
3. **声明类型**：根据确认的契约定义或补充 TypeScript 接口。
4. **精炼实现**：编写精炼、直观的消费逻辑，只在确有业务需求的展示位上设置业务默认值。

---

## 拓展参考
- 更多详细的正反对比案例请阅读：[Bad vs Good 案例详解](./examples/bad-vs-good.md)
