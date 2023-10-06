# Radio Button Interactivity

First, examine how radio buttons are configured in HTML:
![image](https://github.com/department-of-veterans-affairs/LEAF-Developer-Examples/assets/16783916/12ba18b0-b53a-4b6e-a887-91d0d6a05cf5)

Note that because each radio option is a separate element, it has a different unique ID. This means that we can’t select the input by using this syntax:
```js
$('#{{ iID }}').on('change', ...
```

jQuery provides useful shorthand notation, but the abstraction makes it harder to see what really happens. I’m going to use plain JS in the rest of this explanation.
 
The plain JS version of the previous jQuery line is:
```js
document.querySelector('#{{ iID }}').addEventListener('change', ...
```
Since selecting the ID would only yield one of the radio selections, we need to find a common denominator between all radio elements.
 
There are a few options, however the HTML specification uses the “name” attribute, so we’ll use that. Since there’s more than one identical value for the “name” attribute, you will want to get a reference to all of them:
The JS function and CSS selector we should use to get all references is:
```js
document.querySelectorAll('input[name="{{ iID }}"]')
```
 
We can assign the selections into a variable:
```js
let elements = document.querySelectorAll('input[name="{{ iID }}"]');
```
 
Then iterate through the selections, and add a change event listener for each element:
```js
elements.forEach(element => {
    element.addEventListener('change',…
});
```
 
Now, retrieving the value associated with each element can be done in a few ways as well.
 
In the first way, we can take advantage of the fact that the event passes through data associated with the element:
```js
elements.forEach(element => {
    element.addEventListener('change', function(event) {
        console.log(event.target.value);
    }
});
```
 
Another way is to use a CSS selector. Because only one radio button can be selected at a time, we can do this:
```js
elements.forEach(element => {
    element.addEventListener('change', function() {
        console.log(document.querySelector('input[name="{{ iID }}"]:checked').value);
    });
});
```
 
Concise example using JS object chaining notation:
```js
document.querySelectorAll('input[name="{{ iID }}"]').forEach(element => {
    element.addEventListener('change', event => {
        console.log(event.target.value);
    });
});
```

Further reading: 
- https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Selectors
- https://developer.mozilla.org/en-US/docs/Web/API/Document/querySelector
- https://developer.mozilla.org/en-US/docs/Web/API/Document/querySelectorAll
- https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Arrow_functions

