const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const path = require('path');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  maxHttpBufferSize: 5 * 1024 * 1024 // 5MB max for image uploads
});

const PORT = 3000;

// Serve static files from public folder
app.use(express.static(path.join(__dirname, 'public')));

// Track connected users
const users = new Map();

io.on('connection', (socket) => {
  console.log(`Socket connected: ${socket.id}`);

  socket.on('join', (nickname) => {
    users.set(socket.id, nickname);
    console.log(`${nickname} joined the chat`);

    // Notify all users
    io.emit('system-message', `${nickname} has joined the chat`);

    // Send updated user count
    io.emit('user-count', users.size);
  });

  socket.on('chat-message', (message) => {
    const nickname = users.get(socket.id);
    if (!nickname) return;

    io.emit('chat-message', {
      nickname,
      message,
      timestamp: new Date().toISOString()
    });
  });

  socket.on('image-message', (data) => {
    const nickname = users.get(socket.id);
    if (!nickname) return;

    io.emit('image-message', {
      nickname,
      imageData: data.imageData,
      timestamp: new Date().toISOString()
    });
  });

  socket.on('get-members', (callback) => {
    const memberList = Array.from(users.values());
    callback(memberList);
  });

  socket.on('logout', () => {
    const nickname = users.get(socket.id);
    if (nickname) {
      users.delete(socket.id);
      console.log(`${nickname} logged out`);

      io.emit('system-message', `${nickname} has left the chat`);
      io.emit('user-count', users.size);
    }
  });

  socket.on('disconnect', () => {
    const nickname = users.get(socket.id);
    if (nickname) {
      users.delete(socket.id);
      console.log(`${nickname} left the chat`);

      io.emit('system-message', `${nickname} has left the chat`);
      io.emit('user-count', users.size);
    }
  });
});

server.listen(PORT, () => {
  console.log(`Classroom Live Chat running on http://localhost:${PORT}`);
});
