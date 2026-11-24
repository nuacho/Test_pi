import { computed, ref, watch } from 'vue'

const STORAGE_KEY = 'todo-list'

function loadTodos() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    const parsed = raw ? JSON.parse(raw) : []
    if (!Array.isArray(parsed)) return []

    return parsed
      .filter((item) => item && typeof item.text === 'string')
      .map((item) => ({
        id: item.id ?? `${Date.now()}-${Math.random().toString(16).slice(2)}`,
        text: item.text,
        done: Boolean(item.done),
      }))
  } catch {
    return []
  }
}

export function useTodos() {
  const todos = ref(loadTodos())
  const filter = ref('all')
  const draft = ref('')

  watch(
    todos,
    (value) => {
      try {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(value))
      } catch {
        /* приватный режим / переполненное хранилище — молча игнорируем */
      }
    },
    { deep: true },
  )

  const visibleTodos = computed(() => {
    if (filter.value === 'active') return todos.value.filter((t) => !t.done)
    if (filter.value === 'done') return todos.value.filter((t) => t.done)
    return todos.value
  })

  const activeCount = computed(() => todos.value.filter((t) => !t.done).length)
  const doneCount = computed(() => todos.value.filter((t) => t.done).length)
  const totalCount = computed(() => todos.value.length)

  function add(text = draft.value) {
    const value = String(text ?? '').trim()
    if (!value) return false

    todos.value.push({
      id: `${Date.now()}-${Math.random().toString(16).slice(2)}`,
      text: value,
      done: false,
    })
    draft.value = ''
    return true
  }

  function toggle(id) {
    const todo = todos.value.find((t) => t.id === id)
    if (todo) todo.done = !todo.done
  }

  function update(id, text) {
    const value = String(text ?? '').trim()
    const todo = todos.value.find((t) => t.id === id)
    if (!todo) return false
    if (!value) {
      remove(id)
      return false
    }
    todo.text = value
    return true
  }

  function remove(id) {
    todos.value = todos.value.filter((t) => t.id !== id)
  }

  function clearDone() {
    todos.value = todos.value.filter((t) => !t.done)
  }

  function clearAll() {
    todos.value = []
  }

  return {
    todos,
    draft,
    filter,
    visibleTodos,
    activeCount,
    doneCount,
    totalCount,
    add,
    toggle,
    update,
    remove,
    clearDone,
    clearAll,
  }
}
