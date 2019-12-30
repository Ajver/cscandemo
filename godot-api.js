
const godotEventsArray = [];
let currentEventIndex = 0;

class GodotEvent {
    constructor(name, data) {
        this.name = name;
        this.data = data;
    }
}

const newGodotEvent = (name, data) => {
    godotEventsArray.push(new GodotEvent(name, data));
}

const hasEvent = () => {
    return currentEventIndex < godotEventsArray.length;
}

const popEvent = () => {
    return godotEventsArray[currentEventIndex++];
}

const clearEventsArray = () => {
    // currentEventIndex also stores number of readed events so we remove all readed events from array
    godotEventsArray.splice(0, currentEventIndex);
    currentEventIndex = 0;
}

console.log("Wow, it works!")
alert("foo test")