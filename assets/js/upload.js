export const Upload = csrf => ({
  mounted() {
    this.el.addEventListener('drop', e => {
      e.preventDefault();
      e.stopImmediatePropagation();
      const dir = this.el.dataset.cwd;
      const files = e.dataTransfer.files;

      const forms = Array.from(files).map(file => {
        const fd = new FormData();
        fd.append('file', file, file.name);
        fd.append('dir', dir);
        return fetch('/upload', {
          body: fd,
          method: 'post',
          headers: {'x-csrf-token': csrf},
        });
      });

      for (let f of forms) {
        f.then(() => this.pushEventTo('#ls', 'refresh'))
      }
    });

    this.el.addEventListener('dragover', e => {
      e.preventDefault();
      e.stopImmediatePropagation();
    });
  },
});
