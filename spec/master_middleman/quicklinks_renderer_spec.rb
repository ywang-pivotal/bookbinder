require_relative '../../lib/bookbinder'
require_relative '../../master_middleman/quicklinks_renderer'

describe QuicklinksRenderer do

  describe '#header' do
    it 'renders the quicklinks' do
      expected_html = <<EOT
<div class="quick-links"><ul><li>
<a href="#id2">Text2</a><ul><li><a href="#id3">Text3</a></li></ul>
</li></ul></div>
EOT

      page_src = <<-EOT
## <a id="id2"></a>Text2
### <a id="id3"></a>Text3
      EOT
      expect(Redcarpet::Markdown.new(QuicklinksRenderer).render(page_src)).to eq(expected_html.chomp)
    end

    context 'when an h3 is included before any h2s' do
      it 'raises a BadHeadingLevelError' do
        expected_error = <<EOT
The header "<a id="backing-up"></a>Backing Up and Restoring", which is at level 3 has no higher-level headers occuring before it.
EOT

        page_src = <<-EOT
### <a id="backing-up"></a>Backing Up and Restoring
EOT
        expect {
          Redcarpet::Markdown.new(QuicklinksRenderer).render(page_src)
        }.to raise_error(QuicklinksRenderer::BadHeadingLevelError, expected_error.chomp)
      end
    end
  end
end