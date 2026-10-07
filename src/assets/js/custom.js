const API_URL = "https://lz24lf8mr6.execute-api.us-east-2.amazonaws.com";

// Custom JS
document.addEventListener('DOMContentLoaded', () => {
  console.log('Bootstrap + Vite setup is ready!');
});

document.addEventListener("click", (e) => {
  const botao = e.target.closest("[data-produto]");
  if (!botao) return;
  fetch(`${API_URL}/clique/${botao.dataset.produto}`, {
    method: "POST",
    keepalive: true,
  }).catch(() => {});
});
