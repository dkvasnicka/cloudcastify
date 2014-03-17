module namespace page = 'http://basex.org/modules/web-page';
declare namespace rest = 'http://exquery.org/ns/restxq';
declare namespace json = 'http://basex.org/modules/json';
declare namespace sptfy = 'http://www.spotify.com/ns/music/1';

declare %rest:path("spotify")
        %rest:POST
        %rest:form-param("url", "{$url}")
        %output:method("json")
        function page:spotify($url as xs:string) {
    
    let $cloudcast := http:send-request(
        <http:request method="get" href="{fn:replace($url, "http://www", "http://api")}" />)
    let $tracks := json:parse($cloudcast[2])/json/sections/_/track
        return
            <json arrays="json" objects="_"> {
            for $t in $tracks
                let $spotify_track := http:send-request(<http:request method="get" 
                    href="https://ws.spotify.com/search/1/track?q={fn:encode-for-uri($t/name)}" />)[2]
                let $trk := $spotify_track/sptfy:tracks/sptfy:track[contains(sptfy:name, $t/name) and sptfy:artist/sptfy:name/text() = 
                                                                                                  $t/artist/name/text()][1]
                where $trk
                return
                    <_> { 
                        <artist> { $trk/sptfy:artist/sptfy:name[contains(., $t/artist/name)]/text() } </artist>,
                        <name> { $trk/sptfy:name/text() } </name>,
                        <href> { string($trk/@href) } </href> 
                    } </_>
                
            } </json>
};

