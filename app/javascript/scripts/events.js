import { Calendar } from '@fullcalendar/core'
import dayGridPlugin from '@fullcalendar/daygrid'
import timeGridPlugin from '@fullcalendar/timegrid'
import listPlugin from '@fullcalendar/list'
import interactionPlugin from '@fullcalendar/interaction'
const dayjs = require('dayjs');

document.addEventListener('DOMContentLoaded', function () {
  var calendarEl = document.getElementById('calendar')
  if (!calendarEl) return
  document.body.addEventListener("ajax:success", (e) => {
    var event = e.detail[0]
    if(event.updated) { calendar.getEventById(event.id).remove() }
    calendar.addEvent(event)
    window.myModal.hide()
  })

  var calendar = new Calendar(calendarEl, {
    customButtons: {
      viewAllEvents: {
        text: 'All events',
        click: function() {
          calendar.getEventSources()[0].remove()
          calendar.addEventSource('/events/all.json')
        }
      },
      viewMyEvents: {
        text: 'My events',
        click: function() {
          calendar.getEventSources()[0].remove()
          calendar.addEventSource('/events.json')
        }
      }
    },
    plugins: [ dayGridPlugin, interactionPlugin, timeGridPlugin, listPlugin ],
    initialView: 'dayGridMonth',
    aspectRatio: 3.2,
    selectable: true,
    editable: true,
    longPressDelay: 0,
    events: '/events.json',
    nextDayThreshold: '06:00:00',
    headerToolbar: {
      left: 'prev,next viewAllEvents viewMyEvents',
      center: 'title',
      right: 'dayGridMonth,listWeek'
    },

    select: function(info) {
      getScript("events/new", function(){
        document.getElementById("event_start").value = dayjs(info.startStr).format('YYYY-MM-DDTHH:mm')
        document.getElementById("event_end").value = dayjs(info.endStr).format('YYYY-MM-DDTHH:mm')
      })
      calendar.unselect()
    },
    eventClick: function(info) {
      getScript(`events/${info.event.id}/edit`)
    },
    eventDrop: function(info) {
      var event_data = {
        event: {
          start: info.event.startStr,
          end: info.event.endStr
        }
      }
      var xhr = new XMLHttpRequest()
      xhr.open('PATCH', `events/${info.event.id}`)
      xhr.setRequestHeader("Content-Type", "application/json")
      xhr.send(JSON.stringify(event_data))
    },
  })
  calendar.render()
})

function getScript(source, callback) {
  var script = document.createElement('script');
  var prior = document.getElementsByTagName('script')[0];
  script.async = 1;

  script.onload = script.onreadystatechange = function( _, isAbort ) {
      if(isAbort || !script.readyState || /loaded|complete/.test(script.readyState) ) {
          script.onload = script.onreadystatechange = null;
          script = undefined;

          if(!isAbort && callback) setTimeout(callback, 0);
      }
  };

  script.src = source;
  prior.parentNode.insertBefore(script, prior);
}
