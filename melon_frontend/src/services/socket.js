class WebSocketService {
    constructor() {
        this.socket = null;
        this.callbacks = [];
        this.reconnectInterval = 3000;
    }

    connect() {
        const wsUrl = 'ws://localhost:8000/ws/dashboard/';
        this.socket = new WebSocket(wsUrl);

        this.socket.onopen = () => {
            console.log('✅ Connected to Dashboard WebSocket');
        };

        this.socket.onmessage = (event) => {
            const data = JSON.parse(event.data);
            this.notify(data);
        };

        this.socket.onclose = () => {
            console.log('❌ Disconnected. Reconnecting...');
            setTimeout(() => this.connect(), this.reconnectInterval);
        };

        this.socket.onerror = (error) => {
            console.error('WebSocket Error:', error);
        };
    }

    subscribe(callback) {
        this.callbacks.push(callback);
    }

    unsubscribe(callback) {
        this.callbacks = this.callbacks.filter(cb => cb !== callback);
    }

    notify(data) {
        this.callbacks.forEach(cb => cb(data));
    }
}

const socketService = new WebSocketService();
export default socketService;
