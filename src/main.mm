#import <UIKit/UIKit.h>
#include <QApplication>
#include <QMainWindow>
#include <QPushButton>
#include <QVBoxLayout>
#include <QLabel>

// UIViewController para manejar el ciclo de vida nativo de la app en iPadOS
@interface LauncherViewController : UIViewController
@end

@implementation LauncherViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.12 green:0.08 blue:0.18 alpha:1.0]; // Color Ametrine (Púrpura Oscuro)
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 50)];
    titleLabel.text = @"Ametrine Launcher";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:32 weight:UIFontWeightBold];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:titleLabel];
}
@end

int main(int argc, char *argv[]) {
    // Inicialización del motor de la aplicación Qt
    QApplication app(argc, argv);
    
    // Crear una ventana principal Qt básica para el launcher
    QMainWindow mainWindow;
    mainWindow.setWindowTitle("Ametrine Launcher");
    mainWindow.resize(1024, 768);
    
    QWidget *centralWidget = new QWidget(&mainWindow);
    QVBoxLayout *layout = new QVBoxLayout(centralWidget);
    
    QLabel *label = new QLabel("Bienvenido a Ametrine Launcher (Fork de Prism Launcher para iPadOS)", centralWidget);
    label->setAlignment(Qt::AlignCenter);
    label->setStyleSheet("font-size: 24px; color: #E0B0FF; font-weight: bold;");
    
    QPushButton *btnPlay = new QPushButton("Iniciar Minecraft Java (Adoptium VM)", centralWidget);
    btnPlay->setStyleSheet("background-color: #6C3082; color: white; padding: 12px; font-size: 18px; border-radius: 8px;");
    
    layout->addWidget(label);
    layout->addWidget(btnPlay);
    
    mainWindow.setCentralWidget(centralWidget);
    mainWindow.show();
    
    return app.exec();
}
