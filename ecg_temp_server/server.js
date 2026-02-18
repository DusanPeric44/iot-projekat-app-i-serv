const WebSocket = require("ws");

const wss = new WebSocket.Server({ port: 8080 });

console.log("WebSocket server running on port 8080");

wss.on("connection", (ws) => {
  console.log("ESP32 or client connected");

  ws.on("message", (message) => {
    const data = message.toString();
    console.log("Received:", data);

    // broadcast to all clients (mobile app etc.)
    wss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(data);
      }
    });
  });

  ws.on("close", () => {
    console.log("Client disconnected");
  });
});
