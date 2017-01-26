# eidGateway
BeID gateway. Pushes BeID events (terminal attached/detached and card inserted/removed) data to the browser over a Server Side Event. No need for the java applet.

Open a Server Side Event stream and every card event will be pushed to the browser. 

```javascript
    var es = new EventSource('/stream/eid');
    es.onmessage = function (e) {
        console.log(e.data);
        var data = JSON.parse(e.data);
        console.log(data);   
    };
```    


This is a rack application.

 **start:**
 ```sh
 rackup -o 127.0.0.1 -p 5000
 ```
 
 **test page:** http://127.0.0.1:5000
 