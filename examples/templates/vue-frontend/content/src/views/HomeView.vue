<script setup lang="ts">
// This starter template is using Vue 3 <script setup> SFCs
// Check out https://vuejs.org/api/sfc-script-setup.html#script-setup
</script>

<template>
  <main>
    <div class="wrapper">
      <h1>Welcome to ${{ values.name }}</h1>
      <p>${{ values.description }}</p>
    </div>
  </main>
</template>

<style scoped>
main {
  padding: 2rem;
  text-align: center;
}

.wrapper {
  max-width: 800px;
  margin: 0 auto;
}

h1 {
  font-size: 3rem;
  margin-bottom: 1rem;
  color: var(--vt-c-text-1);
}

p {
  font-size: 1.2rem;
  color: var(--vt-c-text-2);
}
</style>