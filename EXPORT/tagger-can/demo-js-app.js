
window.addEventListener('load', () => {
	// Called 20 times per second
	window.setInterval(() => {
		
		if(window.gatewayToJS.hasEvent()) {		
			do {
				const event = window.gatewayToJS.popEvent();
				onEvent(event.name, event.data);
			}while(window.gatewayToJS.hasEvent());	
		
			window.gatewayToJS.clearEventsArray();
		}
		
	}, 50);
});

const onEvent = (eventName, eventData) => {
	switch(eventName) {
		case 'ready':
			//createDemoEventButton();
			window.setTimeout(() => {
				window.gatewayToGodot.newEvent("load_model", `{
					"pck_url": "CylCan.pck",
					"model_path": "models/CylCan.tscn"
				}`);
			}, 1000);
			break;
		case 'message_from_godot':
			alert(eventData);
			break;
		default:
			console.log("Unexpected event:", eventName, eventData)
	}
}

const createDemoEventButton = () => {
	const btn = document.createElement('button');
	btn.addEventListener('click', () => {
		window.gatewayToGodot.newEvent('message', 'This message comes from JS App');
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