import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "components"

ApplicationWindow
{
    LocationFormatter     { id: locationFormatter }
    Providers             { id: providers         }

    TabMainPage           { id: tabMainPage       }

    CoverPage             { id: coverPage         }

    initialPage: tabMainPage

    cover: coverPage
}
