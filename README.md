Steam-Management-for-PowerShell
===============================

This is a PowerShell module which helps you manage Steam games by offering the ability to move games to other locations in your file system, such as from your HDD to your SSD.

Note that this only allows you to operate on games installed in the steamapps\common folder, and thus does not support most Source games.
If you'd like to add support for other games, please feel free to fork!

To import this module, run:

```
PS C:\> Import-Module Steam.psm1
```

or add the module to \My Documents\WindowsPowerShell\Steam\Steam.psm1

Run Get-SteamGame to get a list of currently installed Steam Games.

```
PS C:\> Get-SteamGame

    Directory: E:\program files\steam\steamapps\common


Mode                LastWriteTime     Length Name                                                                      
----                -------------     ------ ----                                                                      
d----         2/15/2013      7:29            Age Of Empires 3                                                          
d----         4/11/2013     17:43            Age2HD                                                                    
d----         8/16/2012      4:44            amnesia the dark descent                                                  
d----         8/16/2012     19:14            and yet it moves                                                          
d----         8/16/2012     19:13            Aquaria                                                                   
d----         9/15/2012      1:27            assassin's creed 2                                                        
d----         1/18/2013     22:24            assassin's creed revelations                                              
...
```

Use Move-SteamGame to move Steam Games. Use -Game to specify the name of the game and -Destination to specify the directory to be moved to.
Note that the name of the game must match that show in the Get-SteamGame command, which is essentially the game's Steam directory.

Note that you must have Admin access to use this command.

```
PS C:\WINDOWS\system32> Move-SteamGame -Game Age2HD -Destination 'C:\Steam Games'
```

Specify the -Moved switch on Get-SteamGame to see exclusively those games that have been moved from their original directory.

```
PS C:\WINDOWS\system32> Get-SteamGame -Moved


    Directory: C:\Steam Games


Mode                LastWriteTime     Length Name
----                -------------     ------ ----
d----         4/17/2013      1:47            Age2HD

```

Conversely, using the -NotMoved switch will show only those games that haven't been moved.

If you'd like to restore a steam game, just run Restore-SteamGame.

```
PS C:\WINDOWS\system32> Restore-SteamGame Age2HD
```

Again, this requires admin.

Please leave feedback!