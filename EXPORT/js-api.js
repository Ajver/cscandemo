class EventSystem {
	
	constructor() {
		this.eventsArray = [];
		this.currentEventIndex = 0;
	}
	
	// Creates and pushs the new event to the events array
	newEvent(eName, eData) {
		this.eventsArray.push({
			name: eName, 
			data: eData
		});
	}
	
	// If has any unreaded event
	hasEvent() {
		return this.currentEventIndex < this.eventsArray.length;
	}
	
	// Returning event object and moving counter forwards
	popEvent() {
		return this.eventsArray[this.currentEventIndex++];
	}
	
	getCurrentEvent() {
		return this.eventsArray[this.currentEventIndex];
	}
	
	getCurrentEventName() {
		return this.getCurrentEvent().name;
	}
	
	getCurrentEventData() {
		return this.getCurrentEvent().data;
	}
	
	next() {
		this.currentEventIndex++;
	}
	
	// Called after reading all events in frame. It clears every READED event (and if there is some unreaded one, the function leaves it)
	clearEventsArray() {
		// currentEventIndex also stores number of readed events so we remove all readed events from array
		this.eventsArray.splice(0, this.currentEventIndex);
		this.currentEventIndex = 0;
	}

}

// Events happens in Godot
const godotEvents = new EventSystem();

// Events happens in ReactJS app
const reactEvents = new EventSystem();



