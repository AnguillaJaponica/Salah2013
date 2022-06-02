require 'rexml/document'

# 最終的に、{スピーチの内容: 賛成反対/True, False}というハッシュを作りたい(イケてないが、データの特質上一旦これで)

# スピーチテキストの抽出
# {スピーカー名: スピーチの内容}というハッシュを作成し、配列に格納していく。
# speechのattributesの例は以下
# {"id"=>id='uk.org.publicwhip/debate/2005-11-07c.2.1', "speakerid"=>speakerid='uk.org.publicwhip/member/1638', "speakername"=>speakername='Peter Lilley', "colnum"=>colnum='2', "time"=>time='14:30:00', "url"=>url='http://www.publications.parliament.uk/pa/cm200506/cmhansrd/vo051107/debtext/51107-01.htm#51107-01_spnew2'}
speech_hashes = []
Dir.open(../data) do |dir|
  for item in dir
    doc = REXML::Document.new(File.open(item))
    speech_elements = doc.get_elements('//publicwhip/speech')
    speaker_name = speech_elements['speakername']
    speech_content = speech_elements['p'].text
    speech_hashes << {speaker_name: speech_content}
  end
end

# スピーカーごとの賛成/反対の抽出
# <b>AYES</b>を探す。
# <b>NOES</b>が出てくるまで、<td>の中の人名を見る。
# スピーカー名からMr., Miss, Mrs.を除いたものについて空白区切りで分解し、<td>を空白区切でで分解したものの中に両方含まれたらゴールのハッシュにTrueと一緒に突っ込む。
# <b>NOES</b>が出てきたら、<b>AYES</b>が出てくるまで上のをやる
# また<b>AYES</b>が出てきたら...を繰り返す。

# doc = REXML::Document.new(File.open('debates2005-11-07c.xml'))
# doc.get_elements('//publicwhip/speech/p')
