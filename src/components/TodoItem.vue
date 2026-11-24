<script setup>
import { nextTick, ref } from 'vue'

const props = defineProps({
  todo: { type: Object, required: true },
})

const emit = defineEmits(['toggle', 'remove', 'update'])

const isEditing = ref(false)
const editText = ref('')
const editInput = ref(null)

async function startEdit() {
  editText.value = props.todo.text
  isEditing.value = true
  await nextTick()
  editInput.value?.focus()
  editInput.value?.select()
}

function commitEdit() {
  if (!isEditing.value) return
  isEditing.value = false
  emit('update', editText.value)
}

function cancelEdit() {
  isEditing.value = false
}
</script>

<template>
  <li
    class="group flex items-center gap-3 rounded-xl px-2 py-3 transition-colors hover:bg-sky-400/8 animate-slide-in"
    :class="todo.done && 'opacity-60'"
  >
    <input
      type="checkbox"
      :checked="todo.done"
      :aria-label="`Отметить «${todo.text}»`"
      class="size-5 shrink-0 cursor-pointer accent-sky-400"
      @change="emit('toggle')"
    />

    <template v-if="isEditing">
      <input
        ref="editInput"
        v-model="editText"
        type="text"
        maxlength="200"
        class="min-w-0 flex-1 rounded-lg border border-sky-400/40 bg-slate-800/90 px-2 py-1 text-base text-slate-100 outline-none focus:ring-4 focus:ring-sky-400/20"
        @keydown.enter.prevent="commitEdit"
        @keydown.esc.prevent="cancelEdit"
        @blur="commitEdit"
      />
    </template>

    <template v-else>
      <span
        class="min-w-0 flex-1 cursor-pointer break-words text-slate-100 transition-colors select-none"
        :class="todo.done && 'text-slate-500 line-through decoration-slate-500'"
        :title="todo.text"
        @dblclick="startEdit"
      >
        {{ todo.text }}
      </span>
    </template>

    <button
      v-if="!isEditing"
      type="button"
      title="Редактировать"
      aria-label="Редактировать задачу"
      class="shrink-0 rounded-md px-1.5 py-1 text-slate-400 opacity-0 transition hover:text-sky-400 focus-visible:opacity-100 group-hover:opacity-100"
      @click="startEdit"
    >
      ✎
    </button>

    <button
      v-if="!isEditing"
      type="button"
      title="Удалить"
      aria-label="Удалить задачу"
      class="shrink-0 rounded-md px-1.5 py-1 text-red-500 opacity-0 transition hover:scale-125 focus-visible:opacity-100 group-hover:opacity-100"
      @click="emit('remove')"
    >
      ✕
    </button>
  </li>
</template>
