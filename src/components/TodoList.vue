<script setup>
import TodoItem from './TodoItem.vue'

defineProps({
  todos: { type: Array, required: true },
})

const emit = defineEmits(['toggle', 'remove', 'update'])
</script>

<template>
  <ul v-if="todos.length" class="scrollbar-slim max-h-[50vh] space-y-0.5 overflow-y-auto px-3 py-2 sm:px-4">
    <TodoItem
      v-for="todo in todos"
      :key="todo.id"
      :todo="todo"
      @toggle="emit('toggle', todo.id)"
      @remove="emit('remove', todo.id)"
      @update="emit('update', todo.id, $event)"
    />
  </ul>

  <div v-else class="px-6 py-10 text-center text-sm text-slate-500 italic">
    Пока пусто. Добавьте первую задачу!
  </div>
</template>
