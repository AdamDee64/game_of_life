package game_of_life

import "core:fmt"
import "core:math/rand"

import rl "vendor:raylib"

// window params
WIDTH   :: 1024
HEIGHT  :: 768
FPS     :: 60
TITLE : cstring : "Game of Life"

// cell/grid parameters
CELL_SIZE :: 8
CELL_SPACE :: 1
REC_SIZE :: (CELL_SIZE + CELL_SPACE)

GRID_W :: WIDTH / REC_SIZE
GRID_H :: HEIGHT / REC_SIZE - 100 / REC_SIZE

GRID_X_SPACE :: (WIDTH - GRID_W * REC_SIZE)/2

DARKESTGRAY : rl.Color = {50, 50, 50, 255}
TRAIL: rl.Color = {220, 255, 220, 255}

front : [GRID_W][GRID_H]int
back : [GRID_W][GRID_H]int

cell_colors : [3]rl.Color = {
   rl.LIGHTGRAY,
   rl.DARKPURPLE,
   TRAIL
}

draw_cell :: proc(x, y : int){
   rl.DrawRectangle(GRID_X_SPACE + i32(x) * REC_SIZE, i32(y) * REC_SIZE + CELL_SPACE, CELL_SIZE, CELL_SIZE, cell_colors[front[x][y]])
}

count_neighbors :: proc(x, y: int) -> int{
   neighbors : int
   dx, dy : int
   for dx = -1 ; dx < 2; dx += 1 {
      for dy = -1 ; dy < 2; dy += 1{
         if dx == 0 && dy == 0{continue}
         cell_x := (x + dx) % GRID_W
         cell_y := (y + dy) % GRID_H
         if cell_x < 0 {cell_x = GRID_W - 1}
         if cell_y < 0 {cell_y = GRID_H - 1}
         if front[cell_x][cell_y] == 1 {neighbors += 1}
      }
   }
   return neighbors
}

flag_cell :: proc(i : int) {
   x := (int(rl.GetMouseX()) - GRID_X_SPACE) / REC_SIZE
   y := (int(rl.GetMouseY()) - CELL_SPACE) / REC_SIZE
   if y >= GRID_H || y < 0 || x >= GRID_W || x < 0 {return}
   front[x][y] = i
   if i == 0 {
      back[x][y] = i
   }
}

life_explosion :: proc() {
   for x in 0..<GRID_W {
      for y in 0..<GRID_H{
         front[x][y] = rand.int_max(2)
      }
   }
}

frame := 0

main :: proc() {

   fmt.printf("grid is %d wide and %d high\n", GRID_W, GRID_H)

   paused := true

   // draw a "glider" to start with
   front[11][10] = 1
   front[12][11] = 1
   front[10][12] = 1
   front[11][12] = 1
   front[12][12] = 1

   rl.InitWindow(WIDTH, HEIGHT, TITLE)

   rl.SetTargetFPS(FPS)
   
   for !rl.WindowShouldClose() {

      if rl.IsKeyPressed(rl.KeyboardKey(.SPACE)) {
         paused = !paused
      }

      if paused{
         if rl.IsKeyPressed(rl.KeyboardKey(.P)) {
            life_explosion()
         }
         if rl.IsKeyPressed(rl.KeyboardKey(.X)) {
            clear : [GRID_W][GRID_H]int
            front = clear
            back = clear
         }

         if rl.IsMouseButtonDown(rl.MouseButton(0)){
            flag_cell(1)
         }
         if rl.IsMouseButtonDown(rl.MouseButton(1)){
            flag_cell(0)
         }
      }

      if !paused{
         frame += 1
         if frame == FPS / 10{
            for x in 0..<GRID_W{
               for y in 0..<GRID_H{
                  if count_neighbors(x, y) == 3 {
                     back[x][y] = 1
                  } else if count_neighbors(x, y) == 2 {
                     back[x][y] = front[x][y]
                  } else if front[x][y] == 1 {
                     back[x][y] = 2
                  }
               }
            }
            front = back
            frame = 0
         }
         
      }

      rl.BeginDrawing()
      
      rl.ClearBackground(rl.BLACK)
      for x in 0..<GRID_W{
         for y in  0..<GRID_H{
            draw_cell(x, y)
         }
      }

      if !paused {
         rl.DrawText("Press space to pause and draw", 50, HEIGHT - 75, 30, DARKESTGRAY)
      } else {
         rl.DrawText("Left click on a cell to draw, right click to clear", 50, HEIGHT - 75, 25, rl.GREEN)
         rl.DrawText("Press space to unpause. Press X to clear screen of all life", 50, HEIGHT - 25, 20, DARKESTGRAY)
      }

            
      rl.EndDrawing()
   }

    rl.CloseWindow()

}