export const NewFolder = {
  mounted() {
    this.el.addEventListener('click', e => {
      const name = prompt('folder name');
      if (name) {
        this.pushEventTo('#new-folder', 'new_folder', {name});
      }
    })
  }
};
