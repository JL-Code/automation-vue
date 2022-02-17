<template>
  <div class="about">
    <h1>这是一个关于页面</h1>
    {{ manifestJson }}
  </div>
</template>

<script>
import manifestJson from "@/manifest.json";
export default {
  name: "about",
  data() {
    return {
      manifestJson,
    };
  },
};
</script>
