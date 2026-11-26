<script setup>
import TodoFooter from './components/TodoFooter.vue'
import TodoForm from './components/TodoForm.vue'
import TodoHeader from './components/TodoHeader.vue'
import TodoList from './components/TodoList.vue'
import { useTodos } from './composables/useTodos.js'

const {
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
} = useTodos()
</script>

<template>
  <main class="flex min-h-screen items-center justify-center p-4 sm:p-6">
    <div
      class="w-full max-w-xl overflow-hidden rounded-2xl border border-slate-400/25 bg-slate-900/85 shadow-[0_20px_60px_rgba(0,0,0,0.45)] backdrop-blur-md"
    >
      <TodoHeader :total="totalCount" />
        
      <TodoForm v-model="draft" @add="add()" />

      <TodoList
        :todos="visibleTodos"
        @toggle="toggle"
        @remove="remove"
        @update="update"
      />

      <TodoFooter
        :active-count="activeCount"
        :done-count="doneCount"
        :filter="filter"
        @update:filter="filter = $event"
        @clear-done="clearDone"
        @clear-all="clearAll"
      />
    </div>
  </main>
</template>
