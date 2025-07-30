import { useEffect, useState } from 'react'
import { v4 as uuidv4 } from 'uuid'
import './App.css'

const API_URL = 'https://9dkd2fy1cg.execute-api.eu-west-1.amazonaws.com/dev/todos'

function App() {
  const [todos, setTodos] = useState([])
  const [newTodo, setNewTodo] = useState('')

  // Charger les todos depuis DynamoDB via Lambda
  useEffect(() => {
    fetch(API_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        operation: 'scan',
        payload: {}
      })
    })
      .then(res => res.json())
      .then(data => {
        setTodos(data.data?.Items || [])
      })
      .catch(err => console.error('Erreur lecture todos:', err))
  }, [])

  const addTodo = async () => {
    if (!newTodo.trim()) return

    const todo = {
      id: uuidv4(),
      title: newTodo,
      completed: false
    }

    await fetch(API_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        operation: 'create',
        payload: {
          Item: todo
        }
      })
    })

    setTodos([...todos, todo])
    setNewTodo('')
  }

  const toggleComplete = async (todo) => {
    const updatedTodo = { ...todo, completed: !todo.completed }

    await fetch(API_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        operation: 'update',
        payload: {
          Key: { id: updatedTodo.id },
          UpdateExpression: 'set completed = :c',
          ExpressionAttributeValues: {
            ':c': updatedTodo.completed
          },
          ReturnValues: 'ALL_NEW'
        }
      })
    })

    setTodos(todos.map(t => t.id === todo.id ? updatedTodo : t))
  }

  const deleteTodo = async (id) => {
    await fetch(API_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        operation: 'delete',
        payload: {
          Key: { id }
        }
      })
    })

    setTodos(todos.filter(t => t.id !== id))
  }

  return (
    <div className="app">
      <h1>📝 Todo List</h1>
      <div className="input-section">
        <input
          placeholder="Ajouter une tâche..."
          value={newTodo}
          onChange={e => setNewTodo(e.target.value)}
        />
        <button onClick={addTodo}>Ajouter</button>
      </div>
      <ul className="todo-list">
        {todos.map(todo => (
          <li key={todo.id}>
            <span
              className={todo.completed ? 'completed' : ''}
              onClick={() => toggleComplete(todo)}
            >
              {todo.title}
            </span>
            <button className="delete" onClick={() => deleteTodo(todo.id)}>✖</button>
          </li>
        ))}
      </ul>
    </div>
  )
}

export default App