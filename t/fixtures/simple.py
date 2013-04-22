import pygame

pygame.init()
size = [640, 480]
# a simple comment

screen = pygame.display.set_mode(size)

while True:

    # another simple comment

    for event in pygame.event.get(): # end-of-line comment

        # multi-line comment
        # continues here and on
        # a third line   
        if event.type == pygame.QUIT:
            #	   
            #   
            done=True

#

#No space

pygame.quit()
