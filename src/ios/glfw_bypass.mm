#import <Foundation/Foundation.h>
#import <GameController/GameController.h>
#include <iostream>

// Estructura interna de GLFW para representar el estado del mando físico
struct GLFWgamepadstate {
    unsigned char buttons[15];
    float axes[6];
};

// Constantes de mapeo de botones de GLFW
#define GLFW_GAMEPAD_BUTTON_A               0
#define GLFW_GAMEPAD_BUTTON_B               1
#define GLFW_GAMEPAD_BUTTON_X               2
#define GLFW_GAMEPAD_BUTTON_Y               3
#define GLFW_GAMEPAD_BUTTON_LEFT_BUMPER     4
#define GLFW_GAMEPAD_BUTTON_RIGHT_BUMPER    5
#define GLFW_GAMEPAD_BUTTON_BACK            6
#define GLFW_GAMEPAD_BUTTON_START           7
#define GLFW_GAMEPAD_BUTTON_GUIDE           8
#define GLFW_GAMEPAD_BUTTON_LEFT_THUMB      9
#define GLFW_GAMEPAD_BUTTON_RIGHT_THUMB     10
#define GLFW_GAMEPAD_BUTTON_DPAD_UP         11
#define GLFW_GAMEPAD_BUTTON_DPAD_RIGHT      12
#define GLFW_GAMEPAD_BUTTON_DPAD_DOWN       13
#define GLFW_GAMEPAD_BUTTON_DPAD_LEFT       14

// Constantes de mapeo de ejes analógicos de GLFW
#define GLFW_GAMEPAD_AXIS_LEFT_X            0
#define GLFW_GAMEPAD_AXIS_LEFT_Y            1
#define GLFW_GAMEPAD_AXIS_RIGHT_X           2
#define GLFW_GAMEPAD_AXIS_RIGHT_Y           3
#define GLFW_GAMEPAD_AXIS_LEFT_TRIGGER      4
#define GLFW_GAMEPAD_AXIS_RIGHT_TRIGGER     5

// Función puente exportada para GLFW / LWJGL
extern "C" int ametrine_poll_gamepad(int jid, GLFWgamepadstate* state) {
    @autoreleasepool {
        NSArray<GCController *> *controllers = [GCController controllers];
        if (controllers.count == 0) {
            return 0; // No hay mandos conectados
        }
        
        GCController *controller = nil;
        if (jid < (int)controllers.count) {
            controller = controllers[jid];
        } else {
            controller = controllers.firstObject;
        }
        
        GCExtendedGamepad *gamepad = controller.extendedGamepad;
        if (!gamepad) {
            return 0; // El mando no es compatible con el perfil extendido (MFi/Xbox/PlayStation)
        }
        
        if (state) {
            // Mapeo directo de botones digitales (0 = soltado, 1 = presionado)
            state->buttons[GLFW_GAMEPAD_BUTTON_A]            = gamepad.buttonA.isPressed ? 1 : 0;
            state->buttons[GLFW_GAMEPAD_BUTTON_B]            = gamepad.buttonB.isPressed ? 1 : 0;
            state->buttons[GLFW_GAMEPAD_BUTTON_X]            = gamepad.buttonX.isPressed ? 1 : 0;
            state->buttons[GLFW_GAMEPAD_BUTTON_Y]            = gamepad.buttonY.isPressed ? 1 : 0;
            state->buttons[GLFW_GAMEPAD_BUTTON_LEFT_BUMPER]  = gamepad.leftShoulder.isPressed ? 1 : 0;
            state->buttons[GLFW_GAMEPAD_BUTTON_RIGHT_BUMPER] = gamepad.rightShoulder.isPressed ? 1 : 0;
            
            // Botones auxiliares (Opciones, Menú y Home con comprobación de versión de iOS)
            if (@available(iOS 14.0, *)) {
                state->buttons[GLFW_GAMEPAD_BUTTON_BACK]     = gamepad.buttonOptions.isPressed ? 1 : 0;
                state->buttons[GLFW_GAMEPAD_BUTTON_GUIDE]    = gamepad.buttonHome.isPressed ? 1 : 0;
            } else {
                state->buttons[GLFW_GAMEPAD_BUTTON_BACK]     = 0;
                state->buttons[GLFW_GAMEPAD_BUTTON_GUIDE]    = 0;
            }
            state->buttons[GLFW_GAMEPAD_BUTTON_START]        = gamepad.buttonMenu.isPressed ? 1 : 0;
            
            // Clic de los joysticks (L3 / R3)
            if (@available(iOS 12.1, *)) {
                state->buttons[GLFW_GAMEPAD_BUTTON_LEFT_THUMB]  = gamepad.leftThumbstickButton.isPressed ? 1 : 0;
                state->buttons[GLFW_GAMEPAD_BUTTON_RIGHT_THUMB] = gamepad.rightThumbstickButton.isPressed ? 1 : 0;
            } else {
                state->buttons[GLFW_GAMEPAD_BUTTON_LEFT_THUMB]  = 0;
                state->buttons[GLFW_GAMEPAD_BUTTON_RIGHT_THUMB] = 0;
            }
            
            // D-Pad (Cruceta direccional)
            state->buttons[GLFW_GAMEPAD_BUTTON_DPAD_UP]      = gamepad.dpad.up.isPressed ? 1 : 0;
            state->buttons[GLFW_GAMEPAD_BUTTON_DPAD_DOWN]    = gamepad.dpad.down.isPressed ? 1 : 0;
            state->buttons[GLFW_GAMEPAD_BUTTON_DPAD_LEFT]    = gamepad.dpad.left.isPressed ? 1 : 0;
            state->buttons[GLFW_GAMEPAD_BUTTON_DPAD_RIGHT]   = gamepad.dpad.right.isPressed ? 1 : 0;
            
            // Mapeo directo de Ejes analógicos (-1.0 a 1.0)
            state->axes[GLFW_GAMEPAD_AXIS_LEFT_X]   = gamepad.leftThumbstick.xAxis.value;
            // GLFW asume Y positivo hacia abajo; UIKit lo asume hacia arriba. Invertimos el eje:
            state->axes[GLFW_GAMEPAD_AXIS_LEFT_Y]   = -gamepad.leftThumbstick.yAxis.value;
            
            state->axes[GLFW_GAMEPAD_AXIS_RIGHT_X]  = gamepad.rightThumbstick.xAxis.value;
            state->axes[GLFW_GAMEPAD_AXIS_RIGHT_Y]  = -gamepad.rightThumbstick.yAxis.value;
            
            // Gatillos analógicos (L2 / R2 - rango 0.0 a 1.0)
            state->axes[GLFW_GAMEPAD_AXIS_LEFT_TRIGGER]  = gamepad.leftTrigger.value;
            state->axes[GLFW_GAMEPAD_AXIS_RIGHT_TRIGGER] = gamepad.rightTrigger.value;
            
            return 1; // Datos de mando obtenidos y actualizados correctamente
        }
        return 0;
    }
}
