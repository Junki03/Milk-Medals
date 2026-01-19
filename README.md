🥛 Milk Medals for Trackmania 2020 🥛

Milk Medals is a bridge-difficulty plugin designed to fill the "no-man's land" between the Gold Medal and the Author Medal (AT).

If Gold feels too easy but the Author feels impossible, it’s time to go for the Milk.

🧪 The Formula 

The Medal is calculated using a 0.40 ratio (may change on feedback). 

It targets the upper-tier of the gap between Gold and AT:

$$\text{MilkTime} = \text{AuthorTime} + (\text{GoldTime} - \text{AuthorTime}) \times 0.40$$

Standard Tracks: It sits at 40% of the way from the Author Time toward the Gold Time.

Short Tracks (Gap < 800ms): The plugin automatically switches to a 50/50 split to ensure the medal remains a distinct, achievable milestone.

✨ Features

Live Notifications: Get a custom "Milk Medal Earned!" toast notification when you archieve the time. (I also want to add a small audio cue but i can't understand how it works. Help is always welcome!!)

UME Integration: Fully compatible with Ultimate Medals Extended, allowing the Milk Medal to appear alongside standard and other popular medals.

Customizable:

 Toggle the standalone HUD.

 Show/Hide deltas.

 Lock HUD position to prevent accidental dragging.

 Auto-hide when the game interface is toggled off.

📜 Changelog

v1.0.0
Initial Release: 

-Core "Milk Medal" logic implemented.

-Dynamic Scaling: Added logic to handle short maps (sub-800ms gaps) by defaulting to a 50/50 split.

-HUD Optimization: Added Delta tracking and interface-aware visibility.

-UME Support: Full integration with Ultimate Medals Extended for unified UI.

-Session Management: Implemented dictionary tracking to prevent notification spam.

🤝 Credits

This is my firts project not only on OpenPlanet but on coding as a whole, it was a blast.

Developed by: J_unki

Special thanks to Ford and ArEyeses who helped me on the OpenPlanet discord.

(i also used AI to understand stuff without spamming the discord, the code has been changed and made readable as per request of the rules. some parts still remained as i deemed them to be the best course of action)
