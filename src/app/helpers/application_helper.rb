module ApplicationHelper

  def display_var_type(snp_id, var_type, genes)
    html = ''
    if var_type
      html = "<span id='transcript_annot_btn-#{snp_id}-#{var_type.name}' data-bs-toggle='tooltip' data-bs-placement='bottom' data-bs-html='true' class='transcript_annot_btn badge bg-#{var_type.impact_class}' title='#{var_type.description}'>#{var_type.name}
           <br/>"
      if genes.size > 0
        html += "<small>#{genes.first[0]}" +
                ((genes.size > 1) ? (" & " + (genes.size-1).to_s + " other" + ((genes.size > 2) ? 's' : '')) : '') +
                "</small>"
      end
      html += "</span>"  
    end
    return html
  end

  def download_buttons id

    html = "<button id='download-btn_#{id}' type='button' class='btn btn-sm btn-primary download-btn ms-3' style='float:right'><i class='fa fa-download'></i> Data</button>\
           <button id='save-svg-btn_#{id}' type='button' class='btn btn-sm btn-primary save-svg-btn ms-3' style='float:right'><i class='fa fa-download'></i> SVG</button>\
           <button id='save-png-btn_#{id}' type='button' class='btn btn-sm btn-primary save-png-btn ms-3' style='float:right'><i class='fa fa-download'></i> PNG</button>"
    return html
  end
  
  def display_user u
    html = (u.name and u.name != '') ? u.name : u.email.split("@").first
    return html
  end

  def display_corr_num i, e
    
    val = ''
    de = e.dup
    ef = e.dup.to_f
    if e != 'NaN'
      sci_val = '%.3E' % e 
      order_magn = 0
      
      if m = sci_val.match(/[+-](\d+)$/)
        order_magn = m[1]
      end
      if i < 3 and i > 0 and  order_magn.to_i.abs > 3
        if m = sci_val.to_s.match(/^(.+?)E([+-])(\d+)$/)
          val = "#{m[1]}e<sup>" + ((m[2] == '-') ? "-" : "") + "#{m[3].to_i}</sup>"  # sci_val.gsub("$(.+?)E([+-])(\d+)$", "e<sup>\1</sup>")
        end
      elsif i == 3 or ef == 0.0 or ef.round(0).to_f == ef.round(3) ## last test is to display 1 for values like 1.0000000000003
        val = ef.round(0).to_s 
      else
        #        if i==0
        #          val = ef #ef.round(3).to_s + "_" + (ef..to_f == ef).to_s
        #        else
        val = ef.round(3).to_s #+  "_" + ef.round(3).to_s + "_" + (ef.round(0).to_f == ef.round(3)).to_s
        #        end
      end
    else
      val = (i == 0) ? "0" : "1"
    end
    
    return val 
    
  end
  
  def display_variant val
    res = ''
    if val.size > 10 
      short = val[0,20]  
      res = "#{short}..."
    else 
      res = val 
    end
    return res
  end
  
  def display_source_type p, h_summary_types
    compl = nil
    if p.is_summary == true
      if s = h_summary_types[p.summary_type_id]
        compl = s.name
      else
        compl = 'na'
      end
    else
      compl = "Dataset " + p.dataset_id.to_s
    end
    html = "<span class='badge bg-info'>" + ((p.is_summary == true) ? "Summary" : "By sample") + ((compl) ? " [#{compl}]" : "") + "</span>"
    
    return html 
  end
  
  def display_value_type p
    html = "<span class='badge bg-info'>" + ((p.is_numeric == true) ? "Numeric" : 'Text') + "</span>"
    html += " <span class='badge bg-info'>" + ((p.is_continuous == true) ? "Continuous" : "Discrete") + "</span>"
    return html
  end
  
  def display_repository_identifiers s
    h_urls = {
      "GSE" => "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=\#{ID}",
      "E-MTAB-" => "https://www.ebi.ac.uk/biostudies/arrayexpress/studies/\#{ID}",
      "E-MEXP-" => "https://www.ebi.ac.uk/biostudies/arrayexpress/studies/\#{ID}",
      "SRP" => "https://trace.ncbi.nlm.nih.gov/Traces/?view=study&acc=\#{ID}",
      "PRJNA" => "https://www.ncbi.nlm.nih.gov/bioproject/?term=\#{ID}"
    }
    return (s.repository_identifiers) ? s.repository_identifiers.split(/\n/).map{|e| t = e.split(": "); id=t[0];
                                          tag=(id) ? id.gsub(/\d+/, '') : '-'; link_to(t[0], (h_urls[tag]) ? h_urls[tag].gsub(/\#\{ID\}/, t[0]) : '', {:class => 'badge bg-info', :target => '_blank'}) + " #{t[1]}"}.join("<br/>") : '<i>None</i>'
  end
  
  def display_reference s
    html = "<i>#{s.authors}, #{s.year}</i><br/>#{s.title}<br/>
    <i>[<a href='https://doi.org/#{s.doi}' target='_blank'>#{s.doi}</a>]</i>"
    if s.flybase_ref
     html += "<i>[<a href='https://flybase.org/reports/#{s.flybase_ref}' target='_blank'>#{s.flybase_ref}</a>]</i><br/>" #.encode!('UTF-8', :undef => :replace, :invalid => :replace, :replace => "")
    end           
    return html
  end

  def display_reference_short s
    return "#{s.authors}, #{s.year}"
  end

  def display_reference_short2 s
    return (s) ? link_to("#{s.authors}, #{s.year}", study_path(s), {:target => "_blank", :class => 'badge bg-info nodec'}) : ''
  end

  def display_reference_short3 s
    return (s) ? link_to("#{s.authors}, #{s.year}", study_path(s), {:target => "_blank", :class => 'badge bg-secondary nodec'}) : ''
  end
  
  def display_categories s, h_cats_by_study, h_cats
    return h_cats_by_study[s.id].map{|cat_id| "<span class='badge bg-info'>" + h_cats[cat_id].name + "</span>"}.join(" ")
  end


  def display_phenotype p
    html = ''
    #link = ((curator?) ? edit_phenotype_path(p) : phenotype_path(p))
    link = phenotype_path(p) 
    if curator?
      html = link_to(raw(p.name), link, { "data-bs-toggle" => 'tooltip', "data-bs-placement" => 'bottom', "data-bs-html"=>'true', :title => p.description, #.gsub(/<\/?su[bp]>/, ''),
                                          :target => '_blank', :class => "pheno_link badge #{(p.obsolete == true) ? 'bg-secondary' : 'bg-info'} nodec"})
    elsif p.obsolete == false
      html = link_to(raw(p.name), link, { "data-bs-toggle" => 'tooltip', "data-bs-placement" => 'bottom', "data-bs-html"=>'true', :title => p.description, #.gsub(/<\/?su[bp]>/, ''),
                                          :target => '_blank', :class => 'pheno_link badge bg-info nodec'})
    end
    return html 
  end
  def display_status s, h_statuses
    status = h_statuses[s.status_id]
    return (status) ? "<div class='badge bg-#{status.css_class}'>#{status.label}</div>" : 'NA'
  end

    def display_date(c)
    n = Time.now
    html = ""
    if n.day == c.day and n.month == c.month and n.year == c.year
      html += "Today"
    elsif n.day == c.day + 1 and n.month == c.month and n.year == c.year
      html += "Yesterday"
    else
      html += "#{c.year}-#{"0" if c.month < 10}#{c.month}-#{"0" if c.day < 10}#{c.day}"
    end
  end

  def display_dgrp_status dgrp_line, h_dgrp_statuses
    status = h_dgrp_statuses[dgrp_line.dgrp_status_id]
    html = ""
    if status
      html =  "<div class='badge bg-#{status.css_class} #{(status.name == 'available') ? "pointer" : ""}'>"
      
      if status.url_mask != ''
        bloomington_id = dgrp_line.name.gsub(/_0*/, '-')
        html += "<a href='#{status.url_mask.gsub(/\{id\}/, bloomington_id)}' data-bs-toggle='tooltip' data-bs-placement='bottom' data-bs-html='true' title='#{status.description}' target='_blank' class='#{(status.name == 'available') ? "badge-link" : ""}'>#{status.label}</a>"
      else
        html += status.label
      end
      html += "</div>"
    end
    return html
  end

  def display_dgrp_line dgrp_line, h_dgrp_statuses
    html = ""
    if dgrp_line
      status = h_dgrp_statuses[dgrp_line.dgrp_status_id]
      if status
        html =  "<div class='badge bg-#{status.css_class} #{(status.name == 'available') ? "pointer" : ""}'>"
        
        if status.url_mask != ''
          bloomington_id = dgrp_line.name.gsub(/_0*/, '-')
          html += "<a href='#{status.url_mask.gsub(/\{id\}/, bloomington_id)}' data-bs-toggle='tooltip' data-bs-placement='bottom' data-bs-html='true' title='#{status.description}' class='#{(status.name == 'available') ? "badge-link" : ""}'>#{dgrp_line.name}</a>"
        else
          html += dgrp_line.name
        end
        html += "</div>"
      end
    else
#      html = 'UNKNOWN DGRP_LINE'
    end
    return html
  end


  
end
