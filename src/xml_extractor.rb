require 'rexml/document'

# 最終的に、{スピーチの内容: 賛成反対/True, False}というハッシュを作りたい(イケてないが、データの特質上一旦これで)
# スピーチテキストの抽出
# {スピーカー名: スピーチの内容}というハッシュを作成し、配列に格納していく。
# speechのattributesの例は以下
# {"id"=>id='uk.org.publicwhip/debate/2005-11-07c.2.1', "speakerid"=>speakerid='uk.org.publicwhip/member/1638', "speakername"=>speakername='Peter Lilley', "colnum"=>colnum='2', "time"=>time='14:30:00', "url"=>url='http://www.publications.parliament.uk/pa/cm200506/cmhansrd/vo051107/debtext/51107-01.htm#51107-01_spnew2'}

# スピーカーごとの賛成/反対の抽出
# <b>AYES</b>を探す。
# <b>NOES</b>が出てくるまで、<td>の中の人名を見る。
# スピーカー名からMr., Miss, Mrs.を除いたものについて空白区切りで分解し、<td>を空白区切でで分解したものの中に両方含まれたらゴールのハッシュにTrueと一緒に突っ込む。
# <b>NOES</b>が出てきたら、<b>AYES</b>が出てくるまで上のをやる
# また<b>AYES</b>が出てきたら...を繰り返す。

def extract_speech_hash(target_dir_elms)
  hashes = []
  Dir.glob(target_dir_elms) do |item|
    doc = REXML::Document.new(File.open(item))
    speech_elements = doc.get_elements('//publicwhip/speech')
    speech_elements.each do |elm|
      speaker_name = elm['speakername']
      content_root_element = elm[1]
      content_element = elm[1].children
      next if speaker_name.nil?
      next if content_root_element.nil?
      next if content_element.nil?

      # 内容が配列に入っている場合と生の文字列で入っている場合がある
      speech_content = 
      if content_element.class == Array
        content_element.first
      elsif content_element.class = String
        content_element
      end

      hashes << {speaker_name => speech_content}
    end
  end  
  hashes
end

train_speech_hashes = extract_speech_hash('./data/scrapedxml/debates/train/*.xml')
test_speech_hashes = extract_speech_hash('./data/scrapedxml/debates/test/*.xml')

# あとはよしなにcsvに落とすなりして利用。