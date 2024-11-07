## About
Mega Man X8 16-bit is a reimagining of the PS2 original with SNES styled graphics. The aim was to demake X8 in a similar feel to the first three Mega Man X games, while trying to actually finish a low-scope fangame. This fangame is fully playable from start to finish with X and runs on Godot Engine 3.5.

## Credits
- Alysson da Paz - Developer, Pixel Art, Sound Mixing
- LuizMiguel - Consulting and Quality Assurance
- Roberto Carlos Martinez Escudero - Spanish Localization
- Samuel "Streg" Oliveira - Megaman 1 Boss Battle Remix

- LuizMiguel, Medivelion, FadinTV, Megamanx_Zero, Shinobi_Speedruns, Koalacwb64, Vhevert, JandersonSilvaJS, SilverZ - Playtesting

- HeaxDePolo, ZafersanToksoz, QuartoDoDu, KaneTV, JulinhoRockman, itzBruHere, OlimTR, CalebHart42, Nostalgia_Games_BR, Meruziin, Fubadas, BadGokuH, Vubidugil, Fixxer0, Bacaxi15, Xopa, MazaKoopa, Orlandobrx, LuizTeles, Zekinoma - Special Thanks

## Notice
Mega Man X8 16-bit is a free fangame. It is not affiliated, associated, authorized, endorsed or in any way connected with CAPCOM or any of it's subsidiaries or it's affiliates.

Mega Man X and all Mega Man/Rockman material is a property of CAPCOM.
Please support the offical release.

## Livesplit Integration

To integrate Livesplit you need to start the TCP server by right clicking Livesplit and then
Control > Start TCP Server
Once this is done, you can establish the connection in game from Options > Livesplit Options > Connection, if it says "UP", you're good to go, if it's stuck on "WAITING", make sure you did start the TCP server and that no other process has taken the network port that Livesplit uses, by default it's port 16834. By default, a local TCP server is assumed to be running (i.e. at IP 127.0.0.1), if you use Livesplit on a different machine, change the value of the IP address accordingly.

If you're using Livesplit One, make sure it says "LIVESPLIT ONE" on Protocol, start the connection first so it says "WAITING", and then on Livesplit One, go to Settings > Network > Server Connection > Connect, on the textbox input `ws://<ip>:<port>` where `<ip>` is the IP of the computer that is running the game (usually the same pc, so 127.0.0.1) and `<port>` must be the port configured ingame (by default it's 16834), so most of the time you'll have to fill it with `ws://127.0.0.1:16834` and then click connect.
