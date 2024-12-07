**PONG GAME**

Group Members:\n
Habiba Elsayed ID: 900221264\n
Omar Leithy ID:900221663\n
Samar Ahmed ID: 900222721\n

Game:
This is our code for a PONG game that allows 2 players to enjoy a game against each other. Our constraint file assumes the use of a Basys-3 board. Player 1 should use the 2 switches on the left, and Player 2 should use the second-to-last 2 switches on the right, as the last switch is reserved for the reset. Upon generating bitstream, the middle push button has to be pressed to start the game. After a player scores 10 points, the game ends and the winner is displayed on the screen.
A buzzer is required to be connected to pin K17 and ground in order for the users to enjoy audio effects.

**Contributions:**

Habiba Elsayed: Worked on outputting the ball on screen and the ascii ROM module which has all the bitmaps for the displayed words. Also worked on displaying the score correctly on screen using the bitmap and the making of the FSM and the conditions and the encoding of each state. 

Omar Leithy: Worked on ensuring the ball’s movement is smooth, and that collisions were handled properly. Also worked on incorporating sound effects into the code using a buzzer as an output, utilizing an FSM to map the sound to every state the ball is in.

Samar Ahmed: Worked on the PONG display, the score system, such that it increments during collision and outputs on the 7-segment display, She has also worked on the FSM, such that the play is a state, and when every text display should be outputted, and when to disable required objects.

For a more detailed report on the code, please refer to our report document in the Milestone 3 file.
