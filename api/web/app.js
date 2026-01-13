async function loadModels() {
  const res = await fetch("/models");
  const data = await res.json();

  const select = document.getElementById("modelSelect");
  data.models.forEach(model => {
    const option = document.createElement("option");
    option.value = model;
    option.textContent = model;
    select.appendChild(option);
  });
   if (select.options.length > 0) {
    select.value = select.options[0].value;
  }
}

loadModels();

async function send() {
  const input = document.getElementById("input");
  const chat = document.getElementById("chat");
  const model = document.getElementById("modelSelect").value;

  const text = input.value.trim();
  if (!text) return;

  chat.innerHTML += `<p><b>Du:</b> ${text}</p>`;
  input.value = "";

  const placeholder = document.createElement("p");
  placeholder.innerHTML = `<i>${model} denkt …</i>`;
  chat.appendChild(placeholder);

  try {
    const res = await fetch("/chat", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        prompt: text,
        model: model
      })
    });

    const data = await res.json();
    placeholder.innerHTML = `<b>${model}:</b> ${data.response}`;
  } catch {
    placeholder.innerHTML = "<b>Fehler:</b> Keine Antwort erhalten.";
  }
}
