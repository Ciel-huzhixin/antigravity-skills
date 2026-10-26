# 精益前端代码案例库 (Bad vs Good)

本案例库旨在通过直观的代码对比，帮助开发者和 AI 明确区分“合理的边界防御”与“恶性的过度防御（如滥用 `||` 猜测字段）”。

---

## 案例 1：列表唯一标识符 (Key/ID)

### ❌ 典型反模式 (Bad)
开发者或 AI 因为不确定后端返回的 ID 是 `id`、`_id`、`uuid` 还是 `code`，堆叠了一堆兜底：
```tsx
return (
  <ul>
    {items.map((item, index) => {
      // 恶劣的反模式：字段猜测 + 下标降级
      const key = item?.id || item?._id || item?.uuid || item?.key || index;
      return <li key={key}>{item?.name || item?.title || 'Item'}</li>;
    })}
  </ul>
);
```

### ✅ 正确做法 (Good)
与后端契约明确或统一约定类型：
```tsx
interface Item {
  id: string;
  name: string;
}

return (
  <ul>
    {items.map(item => (
      <li key={item.id}>{item.name}</li>
    ))}
  </ul>
);
```
> **若不确定字段**：直接向用户提问：“请问接口返回的实体唯一主键字段是 `id` 还是 `_id`？”

---

## 案例 2：分页与响应体结构解构

### ❌ 典型反模式 (Bad)
各种猜测分页字段包装方式：
```typescript
const handlePageChange = async (page: number) => {
  const res = await fetchTableData(page);
  // 猜测分页属性到底叫 pagination 还是 pageInfo 还是直接在顶层
  const total =
    res?.data?.total ||
    res?.data?.totalCount ||
    res?.data?.pagination?.total ||
    res?.total ||
    0;
  const list =
    res?.data?.list ||
    res?.data?.rows ||
    res?.data?.records ||
    res?.list ||
    [];

  setTotal(total);
  setDataSource(list);
};
```

### ✅ 正确做法 (Good)
统一使用项目标准 API 响应结构：
```typescript
interface PaginatedResponse<T> {
  data: {
    records: T[];
    total: number;
    page: number;
  };
}

const handlePageChange = async (page: number) => {
  const { data } = await fetchTableData<PaginatedResponse<User>>(page);
  setTotal(data.total);
  setDataSource(data.records);
};
```

---

## 案例 3：布尔值与状态标志判断

### ❌ 典型反模式 (Bad)
因为不敢确定布尔字段类型到底是 boolean 还是 number 还是 string，做了一堆冗余转换和降级：
```typescript
// 充满防御代码的判断
const isPublished =
  item?.isPublished === true ||
  item?.isPublished === 1 ||
  item?.is_published === 'true' ||
  item?.status === 'PUBLISHED' ||
  item?.status === 1 ||
  false;
```

### ✅ 正确做法 (Good)
明确状态枚举或布尔类型：
```typescript
enum ArticleStatus {
  Draft = 0,
  Published = 1,
}

// 契约明确是枚举还是布尔
const isPublished = item.status === ArticleStatus.Published;
```

---

## 案例 4：表单提交参数构造

### ❌ 典型反模式 (Bad)
构造请求参数时，害怕后端拿不到特定命名，重复塞入多个别名属性：
```typescript
const handleSubmit = (values: FormValues) => {
  const payload = {
    userId: values.userId,
    user_id: values.userId, // 冗余兼容
    id: values.userId,      // 冗余兼容
    userName: values.name,
    username: values.name,  // 冗余兼容
    name: values.name,      // 冗余兼容
  };
  return api.updateUser(payload);
};
```

### ✅ 正确做法 (Good)
严格匹配后端 API 接口要求，不添加任何未约定的冗余字段：
```typescript
interface UpdateUserDto {
  userId: string;
  userName: string;
}

const handleSubmit = (values: FormValues) => {
  const payload: UpdateUserDto = {
    userId: values.userId,
    userName: values.name,
  };
  return api.updateUser(payload);
};
```

---

## 应对未知契约时的标准提问模版

当上下文中确实没有接口文档时，AI 应该使用以下类似模版主动向用户确认：

```markdown
在编写该组件前，为了保证代码精简健壮且避免无意义的冗余字段兜底，请确认以下数据契约：
1. 后端接口返回的列表数据字段是（例如 `res.data.list` 还是 `res.data.records`）？
2. 实体主键和名称字段是（例如 `id` / `name`）？
如果有相关的 TypeScript 接口定义或 JSON 响应示例，请直接发给我。
```
