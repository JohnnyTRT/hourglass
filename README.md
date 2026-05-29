# Hourglass

Hourglass is a KDE Plasma 6 Wallpaper Plugin that allows you change your wallpaper based on the time of day. It only supports static images.


## How to Install

Install via the KDE Plasma 6 official store or locally link Install

## How to Use
![Hourglass logo](readMeImages/instructionalImage1.png)
The above image shows the plugin interface. The wallpaper window has all wallpaper images displayed with the time they are set at (it is in 24 hour time, so 00:00 = 12:00 AM, 21:00 = 9:00 PM, etc)

I have done my best to prevent you from putting in any invalid time or inputs that could break the plugin, but I am not perfect so I will list the rules below:
- Wallpapers must be ordered with earliest time at the top, and latest time at bottom
- Wallpapers can only be added or removed from the end of list (latest time wallpaper) ((I am aware this can be kind of a pain, but it was the easiest way to make the program safe))

Operating the program is as follows:
- to change a wallpaper's image on the list, click its image
- to change a wallpaper's time click its time and type in desired time in HH:MM format (program will correct errors with previous entry)
- to the last wallpaper on list, click remove Last (the list must contain at least one image, so this button is disabled if you have only one entry in the list)

## Transition Modes
There are two transition modes: rigid and smooth

Rigid Transition:
- When the time of the next image in the list is reached, wallpaper will immediatly update to new image

Smoothe Transition:
- Images will smoothly fade to the next image


For Smoothe Transitions:
Since updates happen only every 60 seconds, if you have an two images a minute apart, the program will jump to next image since it only updates every minute.

Also, you may want images to start fading/transitioning at certain times instead of continously fading between each other. In this case, just add each image twice. Give the first instance of each image the time you want it to start, then give the second instance the time you want it to start fading. I am aware this is a suboptimal solution, but it is the simplest way to accomadate both fading continously and at certain times.
