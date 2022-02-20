<template>
  <div class="about">
    <h1>这是一个关于页面</h1>
    <json-viewer
      :value="manifestJson"
      :expand-depth="5"
      copyable
      boxed
      sort
    ></json-viewer>
  </div>
</template>

<script>
import JsonViewer from "vue-json-viewer";
import manifestJson from "@/manifest.json";
export default {
  name: "about",
  components: {
    JsonViewer,
  },
  data() {
    return {
      manifestJson,
    };
  },
};
</script>
<style lang="less" scoped>
.version {
  width: 800px;
  margin: 0 auto;
}
</style>
