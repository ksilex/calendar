import { Calendar } from '@fullcalendar/core'
import dayGridPlugin from '@fullcalendar/daygrid'
import timeGridPlugin from '@fullcalendar/timegrid'
import listPlugin from '@fullcalendar/list'
import interactionPlugin from '@fullcalendar/interaction'
const dayjs = require('dayjs');

document.addEventListener('DOMContentLoaded', function () {
  var calendarEl = document.getElementById('calendar')

  var calendar = new Calendar(calendarEl, {
    plugins: [ dayGridPlugin, interactionPlugin, timeGridPlugin, listPlugin ],
    initialView: 'dayGridMonth',
    aspectRatio: 2.5,
    selectable: true,
    longPressDelay: 0,
    events: '/events.json',
    nextDayThreshold: '06sss:00:00',

    headerToolbar: {
      left: 'prev,next today',
      center: 'title',
      right: 'dayGridMonth,timeGridWeek,listWeek'
    },

    select: function(info) {
      getScript("events/new", function(){
        document.getElementById("event_start").value = dayjs(info.startStr).format('YYYY-MM-DDTHH:mm')
        document.getElementById("event_end").value = dayjs(info.endStr).format('YYYY-MM-DDTHH:mm')
      })
      calendar.unselect()
    }
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
