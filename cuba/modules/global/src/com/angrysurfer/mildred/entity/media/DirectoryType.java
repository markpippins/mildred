package com.angrysurfer.mildred.entity.media;

import javax.persistence.Entity;
import javax.persistence.Table;
import com.haulmont.chile.core.annotations.NamePattern;
import com.haulmont.cuba.core.global.DesignSupport;
import javax.persistence.Column;
import com.haulmont.cuba.core.entity.BaseIntIdentityIdEntity;

@DesignSupport("{'imported':true}")
@NamePattern("%s|name")
@Table(name = "directory_type")
@Entity(name = "mildred$DirectoryType")
public class DirectoryType extends BaseIntIdentityIdEntity {
    private static final long serialVersionUID = 3553221533869704315L;

    @Column(name = "name", unique = true, length = 25)
    protected String name;

    @Column(name = "`desc`")
    protected String desc;

    public void setDesc(String desc) {
        this.desc = desc;
    }

    public String getDesc() {
        return desc;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }


}