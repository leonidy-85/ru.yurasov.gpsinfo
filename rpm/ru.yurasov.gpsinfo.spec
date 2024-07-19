Name:       ru.yurasov.gpsinfo

Summary:    GPSInfo
Version:    0.15.1
Release:    3
Group:      Qt/Qt
License:    GPL-2.0
URL:        https://github.com/leonidy-85/ru.yurasov.gpsinfo

Source0:    %{name}.%{version}.tar.bz2
#Source100:  ru.yurasov.gpsinfo.yaml

Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   qt5-qtdeclarative-import-sensors
Requires:   qt5-qtdeclarative-import-positioning
Requires(post): /bin/touch
Requires(post): %{_bindir}/gtk-update-icon-cache
BuildRequires:  qt5-qtdeclarative-import-sensors
BuildRequires:  qt5-qtdeclarative-import-positioning
BuildRequires:  qt5-qtpositioning-devel
BuildRequires:  desktop-file-utils

%description
An app to show all position information

%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
%qmake5
%make_build

%install
rm -rf %{buildroot}
%qmake5_install

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%defattr(644,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png

%clean
rm -f translations/*.qm
rm -f *.o
rm -f moc_*
rm -f documentation.list
rm -f qrc_resources.*
rm -f Makefile

