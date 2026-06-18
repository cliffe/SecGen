class gitlab_13102::install {
    Exec { path => ['/bin', '/usr/bin', '/sbin', '/usr/sbin']}

    $longgitlab = 'gitlab-ce_13.10.2-ce.0_amd64.deb'
    $gitlabpart = ["${longgitlab}.partaa",
    "${longgitlab}.partab",
    "${longgitlab}.partac",
    "${longgitlab}.partad",
    "${longgitlab}.partae",
    "${longgitlab}.partaf",
    "${longgitlab}.partag",
    "${longgitlab}.partah",
    "${longgitlab}.partai",
    "${longgitlab}.partaj",
    "${longgitlab}.partak",
    "${longgitlab}.partal",
    "${longgitlab}.partam",
    "${longgitlab}.partan",
    "${longgitlab}.partao",
    "${longgitlab}.partap",
    "${longgitlab}.partaq",
    "${longgitlab}.partar",]

    $pkgtobuild = [[$gitlabpart, $longgitlab]]
    $pkgtobuild.each |Array $pkg| {
        gitlab_13102::cpandbuild($pkg[0], $pkg[1])
    }
    exec { 'install_gitlab':
        command => "dpkg -i /tmp/${longgitlab}",
        require => Exec["rebuild-${longgitlab}"],
        timeout => 1800,
    }
    

}
