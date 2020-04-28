export const NewFolder = {
  mounted() {
    this.el.addEventListener('click', e => {
      const name = prompt('folder name');
      if (name) {
        this.pushEvent('new_folder', {name});
      }
    })
  }
};
