package 
{
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.ui.Mouse;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	//import flash.external.ExternalInterface;
	//import flash.net.*;

	public class GameController extends MovieClip
	{
		//Player
		private var player:Player;
		private var IsWinner:Boolean;//Determines if the player won or lost
		
		//Sound
		private var scratchNum:Number = 0;
		private var snd1:Sound = new champion;//champion sound
		private var snd2:Sound = new scratch_sound;//scratch sound
		private var channel:SoundChannel = new SoundChannel();//Plays all of the sounds

		//All variables used to make the circular eraser
		private var r:Number = 10;//Radius of the "eraser". 10 is optimal
		private var x_pos:Number;//x position of the pixel that the mouse is over in the scratch box
		private var y_pos:Number;//y position of the pixel that the mouse is over in the scratch box

		//Handles mouse parameters
		public var currMouseX:Number;
		public var currMouseY:Number;
		public var down:Boolean = false;

		//Objects to be chosen randomly. They will be placed under the scratch box
		private var object0:effluent;
		private var object1:deathstar;
		private var object2:S1;
		private var object3:S2;
		private var object4:S3;
		private var object5:S4;
		private var object6:S5;
		private var object7:S6;
		private var object8:S7;
		private var object9:S8;
		private var object10:S9;
		private var object11:S10;
		private var object12:S11;
		private var object13:S12;
		private var object14:complacency;
		private var object15:tired;
		private var object16:frustration;
		private var object17:rushing;
		private var objectNumber:int = 18;
		private var choices:Array;

		//Box and pixel parameters
		private var SB:Array;//scratch box that is being erased from
		private var box:Box;//Box template to be used for creating the scratch box
		private var x_coord_start:Number = 110;//Starting x-coordinate for the box
		private var y_coord_start:Number = 110;//Starting y-coordinate for the box
		private var box_seperation:Number = 10;//Amount of seperation between each picture
		private var scale:Number = 3;//How large one wants to make the pixels that make up the box. 3 is optimal
		
		//Misc.
		private var check_alpha:Number = -2;//Counter for the number of pixels that have been removed from the scratch box
		private var percentage:Number = 0.90;//Percentage of the box the player must scratch before winning/losing
		private var num:Array;//Holds the 9 pictures
		private var num_counter:int = 0;//Global counter used everywhere

		public function startGame()
		{
			//Decides if the player has won.
			var shazam:Number = Math.round(Math.random());
			if (shazam == 1) IsWinner = true;
			else IsWinner = false;
				
			//Draws the initial boxes
			Mouse.hide();//Hides the mouse so only the coin shows;
			SB = new Array();//Holds every pixel
			box = new Box;//333.95x333.95 pixels
			box.height = 333;//333 pixels
			box.width = 333;//333 pixels
			
			//Draws the red background box
			if (check_alpha < 0)
			{
				var bg:MovieClip = new MovieClip  ;//Backgound
				bg.graphics.beginFill(0xFF0000);//Background colour;
				bg.graphics.drawRect(x_coord_start, y_coord_start, box.height + 42, box.width + 42);
				bg.graphics.endFill();
				mcGameStage.addChild(bg);

				check_alpha++;//increase it so it doesnt redraw
			}

			if (num_counter < 8)
			{
				num = [[],[],[]];
				if (IsWinner == true)//If it is a winning ticket
				{	
					//Calculates nine random numbers between zero and thirteen inclusive
					var win_num:int = Math.floor(Math.random() * objectNumber);
					var place:Array = new Array();
					var place0:Array = [Math.floor(Math.random() * 3),Math.floor(Math.random() * 3)];
					var place1:Array = new Array();
					var place2:Array = new Array();
					var checkArray:Array = [place0];

					for (var a:int = 0; a < 3; a++)
					{
						for (var b:int = 0; b < 3; b++)
						{
							num[a][b] = Math.floor(Math.random() * objectNumber);
						}
					}

					while (checkArray.length < 3)//Calculates three random places to place the winning pictures
					{
						place = [Math.floor(Math.random() * 3),Math.floor(Math.random() * 3)];
						if ((place[0] != place0[0]) && (place[1] != place0[1]))
						{
							if (place1.length == 0)
							{
								place1 = place;
								checkArray.push(place);
							}
							else if ((place[0] != place1[0]) && (place[1] != place1[1]))
							{
								place2 = place;
								checkArray.push(place);
							}

						}
					}

					for (var g:int = 0; g < 3; g++)//Places the three winning pictures
					{
						num[checkArray[g][0]][checkArray[g][1]] = win_num;
					}
				}
				
				else//If the ticket lost
				{
					var numArray:Array = new Array();
					var difference:int;
					for (var c:int = 0; c < objectNumber; c++)
					{
						numArray[c] = c;
						numArray[c + objectNumber] = c;
					}
					for (var d:int = 0; d < 3; d++)
					{
						for (var e:int = 0; e < 3; e++)
						{
							difference = Math.floor(Math.random() * (28 - num_counter));
							num[d][e] = numArray[difference];
							numArray.splice(difference,1);
							num_counter++;
						}
					}			
				}
	
				//Places the pictures onto the screen
				var sel:MovieClip;//Selection
				var x_seperation:Number = box_seperation;
				var y_seperation:Number = box_seperation;

				for (var k:Number = 0; k < 3; k++)
				{
					y_seperation = box_seperation;
					for (var l:Number = 0; l < 3; l++)
					{
						//Handles objects under the left box
						choices_maker();
						sel = choices[num[k][l]];
						choice(sel, x_seperation, y_seperation);
						y_seperation +=  Math.floor(box.height / 3) + box_seperation;
					}
					x_seperation +=  Math.floor(box.width / 3) + box_seperation;
				}
				
			}

			//Draws the scratch box
			if (check_alpha < 0)
			{
				var y_coord:int;
				var x_coord:int = x_coord_start - 5 + box_seperation;

				for (var i:Number = 0; i < box.width + 22; i += scale)
				{
					var bucket:Array = new Array();//An array of all pixels in one row
					y_coord = y_coord_start - 5 + box_seperation;
					x_coord +=  scale;//Moves the x-coordinate

					for (var j:Number = 0; j < box.height + 22; j += scale)
					{
						y_coord +=  scale;
						var rectangle:MovieClip = new MovieClip  ;//One pixel square
						rectangle.graphics.beginFill(0x999999);
						rectangle.graphics.drawRect(x_coord, y_coord, scale, scale);
						rectangle.graphics.endFill();
						mcGameStage.addChild(rectangle);
						bucket[j / scale] = rectangle;
					}
					SB[i / scale] = bucket;//An Array of all pixels
				}
				check_alpha++;//increase it so it doesnt redraw
			}

			//Updates the gamestate
			player = new Player();
			mcGameStage.addChild(player);
			mcGameStage.addEventListener(Event.ENTER_FRAME,update);
			gotoAndStop(1);//Keeps the frame until the player finds out if it won or lost
		}

		private function update(evt:Event)
		{
			//Handles coin movement to follow mouse
			currMouseX = mouseX;
			currMouseY = mouseY;

			//Updates the player
			player.x = currMouseX;
			player.y = currMouseY;
			mcGameStage.addChild(player);

			//Checks if the mouse clicker is down;
			mcGameStage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			function onMouseDown(event)
			{
				down = true;
				mcGameStage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
			function onMouseUp(event)
			{
				down = false;
				mcGameStage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}

			//Executes iff the mouse is held down
			if (down == true)
			{
				//Removes blocks of the scratch boxes
				if ((player.y >= y_coord_start) && (player.y <= y_coord_start + (box.height * 3)))
				{
					if ((player.x >= x_coord_start) && (player.x <= x_coord_start + (box.width * 3)))
					{
						y_pos = Math.floor((currMouseY - y_coord_start) / scale);
						x_pos = Math.floor((currMouseX - x_coord_start) / scale);
						circular_erase();//Hides the boxes in a circular pattern
					}
				}
			}
			check_endGame();//Checks to see if a minimum percentage of the boxes has been scratched
		}

		private function circular_erase()
		{
			for (var i:Number = 0; i < r; i++)
			{
				var counter:int = 0;//Increases the y coordinate to make the circle
				for (var j:Number = 0 + i; j < r; j++)
				{
					if ((i == 0 || i == r-1) && j == r-1)
					{
						//pass. this will make it more circular by taking out the end three pieces.
					}
					else
					{						
						if ((SB[x_pos + i] != undefined) && (SB[x_pos + i][y_pos + counter] != undefined))
						{
							if (SB[x_pos + i][y_pos + counter].alpha == 1)
							{
								SB[x_pos + i][y_pos + counter].alpha = 0;
								check_alpha++;
								scratchNum++;
							}
						}
						if ((SB[x_pos + i] != undefined) && (SB[x_pos + i][y_pos - counter] != undefined))
						{
							if (SB[x_pos + i][y_pos - counter].alpha == 1)
							{
								SB[x_pos + i][y_pos - counter].alpha = 0;
								check_alpha++;
								scratchNum++;
							}
						}
						if ((SB[x_pos - i] != undefined) && (SB[x_pos - i][y_pos + counter] != undefined))
						{
							if (SB[x_pos - i][y_pos + counter].alpha == 1)
							{
								SB[x_pos - i][y_pos + counter].alpha = 0;
								check_alpha++;
								scratchNum++;
							}
						}
						if ((SB[x_pos - i] != undefined) && (SB[x_pos - i][y_pos - counter] != undefined))
						{
							if (SB[x_pos - i][y_pos - counter].alpha == 1)
							{
								SB[x_pos - i][y_pos - counter].alpha = 0;
								check_alpha++;
								scratchNum++;
							}
						}
					}
					counter++;
				}
			}

			if (scratchNum > 0 && (check_alpha <= Math.ceil(Math.pow(box.width/scale,2) * percentage))) {
				scratchNum = 0;
				if (channel.position == 16758.571428571428 || channel.position == 0) {
					var transform:SoundTransform = channel.soundTransform;
					transform.volume = 0.4;
					channel = snd2.play(16330);//Plays the scratch sound
					channel.soundTransform = transform;
				}
			}
		}
		
		private function choices_maker()
		{
			//Objects to be chosen randomly. They will be placed under the scratch box
			object0 = new effluent;
			object1 = new deathstar ;
			object2 = new S1;
			object3 = new S2;
			object4 = new S3;
			object5 = new S4;
			object6 = new S5;
			object7 = new S6;
			object8 = new S7;
			object9 = new S8;
			object10 = new S9;
			object11 = new S10;
			object12 = new S11;
			object13 = new S12;
			object14 = new complacency;
			object15 = new tired;
			object16 = new frustration;
			object17 = new rushing;
			choices = [object0,object1,object2,object3,object4,object5,object6,object7,object8,object9,object10,object11,object12,object13,object14,object15,object16,object17];//Objects for the scratch box
		}

		private function choice(sel:MovieClip, x_seperation:Number, y_seperation:Number)
		{
			//Places the object behind a box
			sel.x = x_coord_start + x_seperation;
			sel.y = y_coord_start + y_seperation;
			mcGameStage.addChild(sel);
		}

		private function check_endGame()//Checks if the player has scratched a certain percentage of the scratch box
		{
			if (num_counter < 10)//So it only does it once
			{
				if (check_alpha > Math.ceil(Math.pow(box.width/scale,2) * percentage))
				{
					num_counter++;//So it only goes to endGame once
					if (IsWinner == true)
					{
						channel.stop();
						channel = new SoundChannel()
						var transform:SoundTransform = channel.soundTransform;
						transform.volume = 0.01;
						channel = snd1.play();
						channel.soundTransform = transform;
						
						gotoAndStop(2);//Frame 2 is the winner frame
					}
					else
					{
						gotoAndStop(3);//Frame 3 is the loser frame
					}
				}
			}
		}

		/*public function getSubString(idNum:Number, addNum:Number, str:String, testChar:String):String {
			var char:String = new String(); //The current character
			var idStr:String = new String(); //The id
			while(1) {
				char = str.substr(idNum+addNum,1);
				if (char == testChar) break;
				idStr = idStr + char;
				addNum++;
			}
			return idStr;
		}*/
	
	}
}