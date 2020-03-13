# AI-algorithms
Implementation of some AI algorithms to see them in action

## Currently there are 2 algorithms implemeted:
### 3x3 puzzle solver which uses A* (A star) heuristic search to find solution to the problem

In any state if user does not know the solution to the puzzle, he/she can tap `Solve` button and search algorithm will find the fastest possible solution, that is illustrated in the gif below:

![](https://media.giphy.com/media/JmDXwWdUPrHGOB9q7W/giphy.gif)

### Ant colony algorithm which attempts to find the shortest path between all the selected dots on the screen

By tapping on the screen user creates places which are to be `visited` and by tapping `Start` user initiates ACO algorithm which attempts to find the shortest path between all dots (places) which exist. Note that ACO algorithm does not guarantee that found path will indeed be the shortest, but it is certainly close to the shortest possible path. Gif below illustrates the user experience:

![](https://media.giphy.com/media/UoRp9YZLaJZ1li0i9r/giphy.gif)
