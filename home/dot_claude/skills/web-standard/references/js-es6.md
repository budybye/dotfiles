# JavaScript ES6+ Reference

## Variables and Scope

### let and const
- `let` - Block-scoped variable
- `const` - Block-scoped constant

### Template Literals
```javascript
const message = `Hello ${name}!`;
const multiline = `
  This is a
  multiline string
`;
```

## Functions

### Arrow Functions
```javascript
// Single parameter
const square = x => x * x;

// Multiple parameters
const add = (a, b) => a + b;

// Block body
const multiply = (a, b) => {
  return a * b;
};
```

### Default Parameters
```javascript
function greet(name = 'World') {
  return `Hello, ${name}!`;
}
```

### Rest Parameters
```javascript
function sum(...numbers) {
  return numbers.reduce((a, b) => a + b, 0);
}
```

## Objects and Arrays

### Destructuring
```javascript
// Object destructuring
const { name, age } = person;

// Array destructuring
const [first, second] = array;

// Renaming variables
const { name: fullName } = person;
```

### Spread Operator
```javascript
// Array spread
const combined = [...array1, ...array2];

// Object spread
const merged = { ...obj1, ...obj2 };

// Function arguments
Math.max(...numbers);
```

### Enhanced Object Literals
```javascript
const obj = {
  // Shorthand property names
  name,
  age,
  
  // Method shorthand
  greet() {
    return `Hello, ${this.name}`;
  },
  
  // Computed property names
  [key]: value
};
```

## Modules

### Export
```javascript
// Named exports
export const PI = 3.14;
export function calculate() {}

// Default export
export default class Calculator {}
```

### Import
```javascript
// Named imports
import { PI, calculate } from './math';

// Default import
import Calculator from './Calculator';

// Namespace import
import * as math from './math';
```

## Classes

```javascript
class Animal {
  constructor(name) {
    this.name = name;
  }
  
  speak() {
    console.log(`${this.name} makes a sound`);
  }
}

class Dog extends Animal {
  constructor(name, breed) {
    super(name);
    this.breed = breed;
  }
  
  speak() {
    console.log(`${this.name} barks`);
  }
}
```

## Promises and Async/Await

### Promises
```javascript
const promise = new Promise((resolve, reject) => {
  // Async operation
  if (success) {
    resolve(result);
  } else {
    reject(error);
  }
});

promise.then(result => {
  // Handle success
}).catch(error => {
  // Handle error
});
```

### Async/Await
```javascript
async function fetchData() {
  try {
    const response = await fetch('/api/data');
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error:', error);
  }
}
```

## Iterators and Generators

### For...of Loop
```javascript
for (const item of iterable) {
  console.log(item);
}
```

### Generator Functions
```javascript
function* idGenerator() {
  let id = 0;
  while (true) {
    yield ++id;
  }
}
```