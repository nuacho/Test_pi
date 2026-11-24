<script setup>
import { tasksLabel } from '../utils/plural.js'

const props = defineProps({
  activeCount: { type: Number, default: 0 },
  doneCount: { type: Number, default: 0 },
  filter: { type: String, default: 'all' },
})

const emit = defineEmits(['update:filter', 'clear-done', 'clear-all'])

const filters = [
  { key: 'all', label: 'Все' },
  { key: 'active', label: 'Активные' },
  { key: 'done', label: 'Готовые' },
]
</script>

<template>
  <footer
    class="flex flex-wrap items-center justify-between gap-3 border-t border-slate-400/15 px-5 py-3.5 text-xs text-slate-400 sm:px-6"
  >
    <span class="tabular-nums">{{ tasksLabel(props.activeCount) }}</span>

    <div class="flex gap-1.5">
      <button
        v-for="item in filters"
        :key="item.key"
        type="button"
        :aria-pressed="filter === item.key"
        class="rounded-full border px-3 py-1 transition-colors"
        :class="
          filter === item.key
            ? 'border-sky-400 bg-sky-400/15 text-sky-400'
            : 'border-slate-400/30 text-slate-400 hover:border-sky-400 hover:text-sky-400'
        "
        @click="emit('update:filter', item.key)"
      >
        {{ item.label }}
      </button>
    </div>

    <div class="flex items-center gap-3">
      <button
        v-if="doneCount"
        type="button"
        class="text-slate-400 underline underline-offset-2 transition hover:text-red-500"
        @click="emit('clear-done')"
      >
        Очистить готовые
      </button>
      <button
        v-if="activeCount || doneCount"
        type="button"
        class="text-slate-500 underline underline-offset-2 transition hover:text-red-500"
        @click="emit('clear-all')"
      >
        Очистить всё
      </button>
    </div>
  </footer>
</template>
