const API_URL = "https://vw3d5efx48.execute-api.us-east-1.amazonaws.com";

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
