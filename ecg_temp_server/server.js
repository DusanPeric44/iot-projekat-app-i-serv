const WebSocket = require("ws");

const wss = new WebSocket.Server({ port: 8080 });
console.log("WS server running on ws://localhost:8080");

wss.on("connection", (ws) => {
  console.log("Client connected.");

  ws.on("message", (msg) => {
    console.log("Data:", msg);

    // broadcast all clients
    wss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) client.send(msg);
    });
  });
});
