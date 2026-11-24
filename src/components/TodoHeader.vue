<script setup>
defineProps({
  total: { type: Number, default: 0 },
})
</script>

<template>
  <header class="border-b border-slate-400/15 px-5 pt-6 pb-4 sm:px-6">
    <h1
      class="bg-[linear-gradient(90deg,#ff4e50,#ffd700,#38bdf8,#c084fc)] bg-[length:300%_auto] bg-clip-text text-2xl font-extrabold tracking-widest text-transparent animate-shine sm:text-3xl"
    >
      Todo List
    </h1>
    <p class="mt-1 text-xs tracking-[0.2em] text-slate-400 uppercase">
      Список задач
      <span v-if="total" class="tracking-normal normal-case text-slate-500">· {{ total }} всего</span>
    </p>
  </header>
</template>
