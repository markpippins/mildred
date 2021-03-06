package com.angrysurfer.mildred.entity.media;

import javax.persistence.Entity;
import javax.persistence.Table;
import com.haulmont.chile.core.annotations.NamePattern;
import com.haulmont.cuba.core.global.DesignSupport;
import java.util.Date;
import javax.persistence.Column;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import com.haulmont.cuba.core.entity.BaseIntIdentityIdEntity;
import com.haulmont.cuba.core.entity.annotation.Lookup;
import com.haulmont.cuba.core.entity.annotation.LookupType;

@DesignSupport("{'imported':true}")
@NamePattern("%s|name")
@Table(name = "directory")
@Entity(name = "mildred$Directory")
public class Directory extends BaseIntIdentityIdEntity {
    private static final long serialVersionUID = -2903971231839915241L;

    @Column(name = "name", nullable = false, length = 767)
    protected String name;

    @Lookup(type = LookupType.DROPDOWN, actions = {"lookup", "open"})
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "directory_type_id")
    protected DirectoryType directoryType;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "effective_dt")
    protected Date effectiveDt;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "expiration_dt")
    protected Date expirationDt;

    @Column(name = "active_flag", nullable = false)
    protected Boolean activeFlag = false;

    public Boolean getActiveFlag() {
        return activeFlag;
    }

    public void setActiveFlag(Boolean activeFlag) {
        this.activeFlag = activeFlag;
    }


    public void setName(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public void setDirectoryType(DirectoryType directoryType) {
        this.directoryType = directoryType;
    }

    public DirectoryType getDirectoryType() {
        return directoryType;
    }

    public void setEffectiveDt(Date effectiveDt) {
        this.effectiveDt = effectiveDt;
    }

    public Date getEffectiveDt() {
        return effectiveDt;
    }

    public void setExpirationDt(Date expirationDt) {
        this.expirationDt = expirationDt;
    }

    public Date getExpirationDt() {
        return expirationDt;
    }


}