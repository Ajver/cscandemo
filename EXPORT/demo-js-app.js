
window.addEventListener('load', () => {
	// Called 20 times per second
	window.setInterval(() => {
		
		if(godotEvents.hasEvent()) {		
			do {
				const event = godotEvents.popEvent();
				onEvent(event.name, event.data);
			}while(godotEvents.hasEvent());	
		
			godotEvents.clearEventsArray();
		}
		
	}, 50);
});

const onEvent = (eventName, eventData) => {
	switch(eventName) {
		case 'ready':
			createDemoEventButton();		
		case 'alert':
			alert(eventData);
		default:
			console.log("Unexpected event:", eventName, eventData)
	}
}

const createDemoEventButton = () => {
	
	const btn = document.createElement('button');
	btn.addEventListener('click', () => {
		reactEvents.newEvent('flip_camera', 'foo');
	})
	
	btn.innerHTML = 'Call JS event';
	
	// I know, that I should do this via css, but it's just demo
	btn.style.position = 'fixed';
	btn.style.right = 0;
	btn.style.top = 0;
	btn.style.zIndex = 10;
	
	const body = document.querySelector('body')
	body.appendChild(btn)
}