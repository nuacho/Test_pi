/**
 * Русская плюрализация: 1 задача / 2 задачи / 5 задач
 */
export function pluralize(count, one, few, many) {
  const mod10 = count % 10
  const mod100 = count % 100

  if (mod10 === 1 && mod100 !== 11) return one
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) return few
  return many
}

export function tasksLabel(count) {
  return `${count} ${pluralize(count, 'задача', 'задачи', 'задач')}`
}
