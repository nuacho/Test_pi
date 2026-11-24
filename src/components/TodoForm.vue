<script setup>
import { ref } from 'vue'

const draft = defineModel({ type: String, default: '' })

const emit = defineEmits(['add'])
const input = ref(null)

function submit() {
  emit('add')
  input.value?.focus()
}
</script>

<template>
  <form class="flex gap-2.5 px-5 py-4 sm:px-6" @submit.prevent="submit">
    <input
      ref="input"
      v-model="draft"
      type="text"
      id="new-todo"
      name="todo"
      maxlength="200"
      autocomplete="off"
      placeholder="Добавить новую задачу..."
      aria-label="Новая задача"
      class="min-w-0 flex-1 rounded-xl border border-slate-400/30 bg-slate-800/80 px-3.5 py-3 text-base text-slate-100 outline-none transition placeholder:text-slate-500 focus:border-sky-400 focus:ring-4 focus:ring-sky-400/20"
    />
    <button
      type="submit"
      title="Добавить"
      aria-label="Добавить задачу"
      class="shrink-0 rounded-xl bg-[linear-gradient(135deg,#38bdf8,#6366f1)] px-5 text-xl font-bold text-white transition hover:brightness-115 hover:-translate-y-px active:translate-y-0"
    >
      +
    </button>
  </form>
</template>
