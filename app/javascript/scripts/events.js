import { Calendar } from '@fullcalendar/core'
import dayGridPlugin from '@fullcalendar/daygrid'
import timeGridPlugin from '@fullcalendar/timegrid'
import listPlugin from '@fullcalendar/list'
import interactionPlugin from '@fullcalendar/interaction'
import rrulePlugin from '@fullcalendar/rrule'
const dayjs = require('dayjs');

document.addEventListener('DOMContentLoaded', function () {
  var calendarEl = document.getElementById('calendar')
  if (!calendarEl) return
  document.body.addEventListener("ajax:success", (e) => {
    var event = e.detail[0]
    if (typeof event !== 'object') return

    if (event.state) calendar.getEventById(event.id).remove()
    if (event.state == 'updated' || event.state == null) calendar.addEvent(event)
    window.myModal.hide()
    console.log(event.state)
  })
  document.body.addEventListener('ajax:error', (e) => {
    var event = e.detail[0]
    var errors = event.errors
    errors.forEach(function(err){
      document.getElementsByClassName('modal-body')[0].insertAdjacentHTML('afterbegin', `
      <div class="alert alert-danger alert-dismissible fade show">
        ${err}
        <button aria-label="Close" class="btn-close" data-bs-dismiss="alert" type="button"></button>
      </div>`)
    })
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
    plugins: [ dayGridPlugin, rrulePlugin, interactionPlugin, timeGridPlugin, listPlugin ],
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
